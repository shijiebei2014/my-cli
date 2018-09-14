var mongoose = require('mongoose');
var colors = require('colors');
var nconf = require('nconf');
const _ = require('underscore');
const path = require('path')

const file_path = path.join(__dirname, 'cli_config.json')

nconf.file({
    'file': file_path
});

// var db_uri = nconf.get('mongodb_uri');

function connect_db(db_uri) {
    console.log(db_uri);
    mongoose.connect(db_uri);
    var db = mongoose.connection;
    db.on('error', console.error.bind(console, 'connection error:'));
    db.on('connecting', function() {
        console.log(colors.green('Connecting to mongodb... '));
    });
    db.on('connected', function() {
        console.log(colors.green('Connected'));
    });
    db.on('open', function() {
        console.log(colors.green('Connection opened!'));
    });
    db.on('close', function() {
        console.log(colors.green('Connection has been closed!'));
    });
    db.on('disconnecting', function() {
        console.log(colors.green('Disconnecting db... '));
    });
    db.on('disconnected', function() {
        console.log(colors.green('Disconnected '));
    });
    return db;
}

const MAP = {
  development: ['127.0.0.1', 'localhost'],
  dev: ['127.0.0.1', 'localhost'],
  qas: 'qas.zhisiyun.com',
  stage: 'stage.zhisiyun.com'
}

module.exports = function(env) {
  var hosts = MAP[env]
  if (!hosts) {
    throw new Error('参数' + env + '不正确')
  }
  hosts = _.isArray(hosts) ? hosts : [hosts]
  var content = require(file_path)

  var keys = _.keys(content)
  var newContent = null
  for (var i = 0; i < keys.length; i++) {
    var k = keys[i],
        v = content[k];
    if (_.find(hosts, function (h) {
      return v.indexOf(h) != -1
    })) { // 匹配
      newContent = v
      break;
    }
  }

  return connect_db(newContent)
}
