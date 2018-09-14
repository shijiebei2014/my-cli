const _ = require('underscore')
const co = require('co')
const colors = require('colors')
const debug = require('debug')('backup:query');
const mydb = require('./mydb')

const MODEL_BASE = '../models'
const CACHE = {}

function getStdin() { // 获得输入信息
  return new Promise((resolve, reject) => {
    var buffer = new Buffer('')
    const dataListener = (data) => {
      // console.log('data:', data);
      buffer = Buffer.concat([buffer, data])
      resolve(buffer.toString().replace(/\s$/g, '')) // 去除末尾的换行符
      process.stdin.removeListener('data', dataListener)
      process.stdin.removeListener('error', errorListener)
    }
    const errorListener = (err) => {
      process.stdin.removeListener('data', dataListener)
      process.stdin.removeListener('error', errorListener)
      reject(err)
    }
    process.stdin.on('data', dataListener)
    process.stdin.on('error', errorListener)
  })
}

function* validModel(modelName) {
  const fs = require('fs')
  const path = require('path');
  if (CACHE[modelName]) {
    return CACHE[modelName]
  }
  const files = yield new Promise((resolve, reject) => { // 获得表结果
    fs.readdir(path.join(__dirname, MODEL_BASE), (err, files) => {
      if (err) {
        return reject(err)
      }
      resolve(files || [])
    })
  })
  var model = null
  debug(files.length)
  for (var i = 0; i < files.length; i++) {
    var file = files[i]
    if (_.contains(['gensee_webcast.js'], file)) {
      continue
    }
    var Mod = require(path.join(__dirname, MODEL_BASE, file))
    if (Mod) {
      if (Mod[modelName]) {
          model = Mod[modelName]
          CACHE[modelName] = model
          break;
      }
      if (Mod.modelName === modelName) {
          model = Mod[modelName]
          CACHE[modelName] = model
          break;
      }
    }
  }
  return model
}

function validCondition (condition) {
  return stringToObject(condition)
}

function stringToObject(string) {
  var ret = null
  console.log('string:', string);
  try {
    ret = JSON.parse(string)
    console.log('ret:', ret)
  } catch (e) {
    debug('json parse err:', e);
  } finally {
    return ret
  }
}

function* getQuery() {
  var first = {
    modelName: {
      desc: '表',
      val: ''
    },
    condition: {
      desc: '条件',
      val: ''
    }
  }, second = {
    select: {
      desc: '字段',
      val: '',
      type: Array
    },
    skip: {
      desc: 'skip',
      val: '',
      type: Number
    },
    limit: {
      desc: 'limit',
      val: '',
      type: Number
    }
  };
  // 构造Query
  var keys = _.keys(first)
  for (var i = 0; i < keys.length; i++) {
    var k = keys[i],
        v = first[k]
    console.log(colors.yellow('请输入' + v.desc + ':'));
    v.val = yield getStdin()
    switch (k) {
      case 'modelName':
        var model = yield validModel(v.val)
        if (!model) {
          throw new Error('表' + v.val + '不存在')
        }
        v.val = model
        break;
      case 'condition':
        console.log('v.val:', v);
        v.val = validCondition(v.val)
        if (!v.val) {
          v.val = {}
        }
        break;
    }
  }

  var query = first.modelName.val.find(first.condition.val)

  // 其他参数
  var keys = _.keys(second)
  for (var i = 0; i < keys.length; i++) {
    var k = keys[i],
        v = second[k]
    console.log(colors.yellow('请输入' + v.desc + (v.type === Array ? '(请用逗号隔开)' : '') + ':'));
    v.val = yield getStdin()
    if (v.type === Number) {
      if (Number(v.val) && !isNaN(Number(v.val))) {
        v.val = Number(v.val)
        query[k](v.val)
      }
    } else if (v.type === Array) {
      var fields = v.val.split(',')
      if (k === 'select') {
        fields = fields.join(' ')
        if (fields) {
          query[k](fields)
        }
      }
    }
  }

  return yield query.exec()
}

co(function* () {
  console.log(colors.yellow('请输入数据库环境(dev,qas,stage)'))
  var env = yield getStdin()

  mydb(env)

  yield new Promise((resolve, reject) => {
    console.log(colors.yellow('稍等......'));
    setTimeout(() => {
      resolve()
    }, 2000)
  })

  // console.log(colors.yellow('请输入表:'));
  // var modelName = yield getStdin()
  // var model = yield validModel(modelName)
  // if (!model) {
  //   throw new Error('表' + modelName + '不存在')
  // }
  // console.log(colors.yellow('请输入条件:'));
  // var condition = yield getStdin()
  // condition = validCondition(condition)
  // if (!condition) {
  //   condition = {}
  // }
  // var query = model.find(condition)
  // console.log(colors.yellow('请输入字段(用逗号隔开):'));
  // var fields = yield getStdin()
  // fields = fields.split(',').join(' ')
  // if (fields) {
  //   query.select(fields)
  // }
  // console.log(colors.yellow('请输入skip和limit(用逗号隔开):'));
  // var skipAndLimit = yield getStdin()
  // var strs = fields.split(',')
  // if (strs.length > 0) {
  //   var skip = Number(strs[0])
  //   if (!isNaN(skip)) {
  //     query.skip(skip)
  //   }
  //   if (strs.length > 0 && !isNaN(Number(strs[1]))) {
  //     query.limit(Number(strs[1]))
  //   }
  // }
  // var results = yield query.exec()
  var is_continue = 'y'
  while (is_continue === 'y') {
    var results = yield getQuery()
    console.log(colors.green('结果如下:'))
    console.log(results)

    console.log(colors.yellow('是否继续(y表示yes,n表示no)'))
    is_continue = yield getStdin()
  }
  process.exit(0)
}).catch((err) => {
  console.error(err.stack);
  console.error(colors.red('报错信息:' + err));
  process.exit(0)
})

// DEBUG=* node backup/query.js
// {"_id":"5b98af7ede2bb24246581195"}
