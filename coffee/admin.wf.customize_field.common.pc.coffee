###
Systemprocesscustomizefieldvalue
###
Spcfv = Backbone.Model.extend {
    idAttribute: "_id"
    rootUrl: '/admin/wf/process_visual_define/customize_value'
    url: ()->
        return this.rootUrl + '/' + this.id
}
###
Systemprocesscustomizefieldvalue Collection
###
Spcfvs = Backbone.Collection.extend {
    model: Spcfv
    rootUrl: '/admin/wf/process_visual_define/customize_value'
    url: ()->
        return this.rootUrl + '/' + $('#customize_pi').val()
}
CustomizeConditionField = Backbone.Model.extend {
    idAttribute: "_id"
    rootUrl: '/admin/wf/process_visual_define/condition/bb'
    url: ()->
        return this.rootUrl + '/' + this.id;
}
CustomizeConditionFields = Backbone.Collection.extend {
    model: CustomizeConditionField,
    url:'/admin/wf/process_visual_define/condition/list',#?condition_type=text
}
ccfs = new CustomizeConditionFields()

formBodyViewOption = {
    el: '',
    template: Handlebars.compile $("#tmp_customize_form_body").html()
    curField: null,
    render: ()->
        self = this
        is_show_customize = false #是否显示附加信息

        render_data = {
            customize_fields: customizeField.getSpcf()
            customize_form: customizeField.getCustomizeForm()
        }

        render_data.customize_form_rows = _.map(_.range(render_data.customize_form.rows), (x)->
            row = {
                row: x
            }
            row.colspan = render_data.customize_form.colspan[x] || false
            return row
        )

        #打印时候用
        if reprint_layout3
            $('#customize_append_info').append(reprint_layout3(render_data))
            $('#layout_view_customize_append_info').append(reprint_layout3(render_data))

            $('#layout_view_customize_append_info .gridtable tr').each (index) -> #隐藏备注
                tds = $(this).find('td');
                flag = true;
                for td in tds
                    if !_.contains(['', '备注'], $(td).text().trim())
                        flag = false;
                        break;

                if flag
                    $(this).hide()
        #打印时候用
        if reprint_layout4
            $('#customize_append_info').append(reprint_layout4(render_data))
            $('#layout_view_customize_append_info').append(reprint_layout4(render_data))

        self.$el.html self.template render_data

        date_fields = self.$el.find(".date_field")
        time_fields = self.$el.find(".time_field")
        datetime_fields = self.$el.find(".datetime_field")
        cascade_fields = self.$el.find ".cascade_field"
        td_id = $('#customize_td').val();
        if date_fields.length > 0
            date_fields.each (index)->
                _id = $(this).attr('id')
                field = _.find _spcf, (x)->
                    return x && x._id == _id
                if field
                    task_editable = _.find field.task_editable, (x)->
                      return x.td == td_id;

                    disabled = if task_editable && task_editable.flag then '' else 'disabled'
                    if !disabled
                        $(this).mobiscroll().calendar {
                            theme: 'mobiscroll'
                            lang: 'zh'
                            display: 'bubble'
                            swipeDirection: 'vertical'
                            controls: ['calendar']
                            startYear: 1900
                            endYear: 2030
                            mode: 'mixed'
                            dateFormat: 'yy-mm-dd',
                            buttons: ['set', 'cancel', {text: '清除', handler: 'clear'}]
                        }
        if time_fields.length > 0
            time_fields.each (index)->
                _id = $(this).attr('id')
                field = _.find _spcf, (x)->
                    return x && x._id == _id
                if field
                    task_editable = _.find field.task_editable, (x)->
                      return x.td == td_id;

                    disabled = if task_editable && task_editable.flag then '' else 'disabled'

                    if !disabled
                        $(this).mobiscroll().calendar {
                            theme: 'mobiscroll'
                            lang: 'zh'
                            display: 'bubble'
                            swipeDirection: 'vertical'
                            controls: ['time']
                            startYear: 1900
                            endYear: 2030
                            mode: 'mixed'
                            dateFormat: 'yy-mm-dd'
                            steps: {
                                minute: 5,
                                zeroBased: true
                            },
                            buttons: ['set', 'cancel', {text: '清除', handler: 'clear'}]
                        }
        if datetime_fields.length > 0
            datetime_fields.each (index)->
                _id = $(this).attr('id')
                field = _.find _spcf, (x)->
                    return x && x._id == _id
                if field
                    task_editable = _.find field.task_editable, (x)->
                      return x.td == td_id;

                    disabled = if task_editable && task_editable.flag then '' else 'disabled'
                    if !disabled
                        $(this).mobiscroll().calendar {
                            theme: 'mobiscroll'
                            lang: 'zh'
                            display: 'bubble'
                            swipeDirection: 'vertical'
                            controls: ['calendar', 'time']
                            startYear: 1900
                            endYear: 2030
                            mode: 'mixed'
                            dateFormat: 'yy-mm-dd'
                            steps: {
                                minute: 5,
                                zeroBased: true
                            },
                            buttons: ['set', 'cancel', {text: '清除', handler: 'clear'}]
                        }
        if cascade_fields.length > 0
            cascade_fields.each (index)->
                _id = $(this).attr('id')
                field = _.find _spcf, (x)->
                    return x && x._id == _id
                if field
                    isDisabled = cxSelectUtil.isDisabled field
                    if isDisabled != 'disabled'
                        api = $('#' + _id).cxSelect {
                            selects: cxSelectUtil.genClassName(field)
                            jsonName: 'name',
                            jsonValue: 'name',
                            jsonSub: 'children'
                            firstTitle: '请选择'
                            data: field.cascade_options[0].children
                        }
        $(".chzn-select").chosen {
            disable_search_threshold: 10
        }
        ###
        如果是数字输入框,只允许输入数字和点号
        ###
        self.$el.find("input[type='number']").keydown (e)->
            e = $(this).event || window.event
            code = parseInt e.keyCode
            ###
            8是backspace
            110是小数点
            45是负号
            ###
            #console.log '-:', '-'.charCodeAt(0)
            if code >= 96 && code <= 105 || code >= 48 && code <= 57 || code == 8 || code==110 || code==45 || code == 190 || code == 189
                return true
            else
                return false

        _.each _spcf, (x)->
            if x && cxSelectUtil.isShow(x)
                is_show_customize = true
                $('#customize_form_body').find('label[data-row="' + x.row + '"][data-col="' + x.col + '"]').show()
                $('#customize_form_body').find('div[data-row="' + x.row + '"][data-col="' + x.col + '"]').show()
                #转正打印,显示自定义字段
                $('#layout_view_customize_append_info').find('td[data-row="' + x.row + '"][data-col="' + x.col + '"]').show()
            else
                #转正打印,隐藏自定义字段
                $('#layout_view_customize_append_info').find('td[data-row="' + x.row + '"][data-col="' + x.col + '"]').hide('')
        if !is_show_customize
            $(self.el).hide()
        return this
    events: {
        'change input,textarea,select': 'changeField'
        'click .btn_add_tr_data': (event)-> #增加一行表格数据
            event.preventDefault()
            self = this
            self.curField = null
            $this = $(event.currentTarget)

            row = $this.data('row')
            col = $this.data('col')
            field = customizeField.get_field2(row, col)

            $table_container = $('#table_' + row + '-' + col)
            $table_form_container = $('#table_form_' + row + '-' + col)
            if field
                if !field.values
                    field.values = []
                field.values.push({})
                render_data = {
                    field: field,
                    data: {},
                    index: field.values.length - 1,
                }
                $table_form_container.html(tmp_form_table_form(render_data))
                $table_form_container.find(".date_field").mobiscroll().calendar({
                    theme: 'mobiscroll',
                    lang: 'zh',
                    display: 'bubble',
                    swipeDirection: 'vertical',
                    controls: ['calendar'],
                    startYear: 2000,
                    endYear: 2030,
                    mode: 'mixed',
                    dateFormat: 'yy-mm-dd'
                })
                $table_form_container.show()
                $this.hide()
                $table_container.find('.btn_edit_tr_data, .btn_remove_tr_data').attr('disabled', true)
        'click .btn_edit_tr_data': (event)-> #编辑一行表格数据
            event.preventDefault()
            self = this
            $this = $(event.currentTarget)
            row = $this.data('row')
            col = $this.data('col')
            index = $this.data('index')
            field = customizeField.get_field2(row, col)
            data = field.values[index]
            self.curField = deepClone(field) #记录当前的数据

            $table_container = $('#table_' + row + '-' + col)
            $table_form_container = $('#table_form_' + row + '-' + col)
            if field
                render_data = {
                    field: field,
                    data: data,
                    index: index
                }
                $table_form_container.html(tmp_form_table_form(render_data))
                $table_form_container.find(".date_field").mobiscroll().calendar({
                    theme: 'mobiscroll',
                    lang: 'zh',
                    display: 'bubble',
                    swipeDirection: 'vertical',
                    controls: ['calendar'],
                    startYear: 2000,
                    endYear: 2030,
                    mode: 'mixed',
                    dateFormat: 'yy-mm-dd'
                })
                $table_form_container.show()
                $('.btn_add_tr_data[data-row=' + row + '][data-col=' + col + ']').hide()
                $table_container.find('.btn_edit_tr_data, .btn_remove_tr_data').attr('disabled', true)
        'click .btn_remove_tr_data': (event)-> #删除一行表格数据
            event.preventDefault()
            self = this
            $this = $(event.currentTarget)
            row = $this.data('row')
            col = $this.data('col')
            index = $this.data('index')
            field = customizeField.get_field2(row, col)
            data = field.values[index]
            if field && data && confirm('确认要删除第[' + (index + 1) + ']行的数据吗？')
                field.values.splice(index, 1)
                self.render()
        'click .btn_save_tr_data': (event)-> #保存一行表格数据
            event.preventDefault()
            self = this
            self.curField = null
            $this = $(event.currentTarget)
            row = $this.data('row')
            col = $this.data('col')
            index = $this.data('index')
            $table_form_container = $('#table_form_' + row + '-' + col)
            $table_form_container.find('select').trigger('change')
            #做表单验证
            field = customizeField.get_field2(row, col)
            data = field.values[index]
            vr = customizeField.validate_table_form_data(field, data)
            if vr.pass
                $table_form_container.hide()
                self.render()
                #resolveCondtionResult(constructTTS())
            else
                alert(vr.errs.join('\n'));
        'click .btn_cancel_tr_data': (event)-> #删除一行表格数据
            event.preventDefault()
            self = this
            if self.curField
                customizeField.setField self.curField
                self.curField = null
            else
                $this = $(event.currentTarget)
                row = $this.data('row')
                col = $this.data('col')
                index = $this.data('index')
                field = customizeField.get_field2(row, col)
                data = field.values[index]
                field.values.splice(index, 1)
            self.render()
    }
    changeField: (e)->
        e.preventDefault();

        $this = $(e.target);
        row = $this.data('row');
        col = $this.data('col');
        data_row = $this.data('data_row');
        data_col = $this.data('data_col');
        value = $this.val();
        field = customizeField.get_field2(row, col);
        if field
            if field.cat == 'str' || field.cat == 'num' || field.cat == 'date' || field.cat == 'time' || field.cat == 'datetime'
                #field['data'] = value;
                if field.ctype == 'cascade'
                    _id = field._id
                    values = cxSelectUtil.getValue(field)
                    customizeField.setField(field, values, 'values')
                    customizeField.setField(field, if _.compact(values).length != 0 then values.join('/') else '')
                else
                    customizeField.setField(field, value)
            else if startWith(field.cat, 'table') #对于表格内部的数据的变化，直接修改数据，等到用户点击“保存”的时候再render
                field.values[data_row][data_col] = value
                customizeField.setField(field, field.values, 'values')
                #是否设定了公式需要计算的
                if field.columns[data_col].cat == 'num'
                    data = field.values[data_row]
                    apply_formula(field, data)
                    render_data = {
                        field: field,
                        data: data,
                        index: data_row
                    }
                    $table_form_container = $('#table_form_' + row + '-' + col);
                    tmp_form_table_form_cal(render_data)
}

CcfView = Backbone.View.extend {
    el: '#ihModalCCF .modal-body',
    template: null
    initialize: ()->
        self = this
        if $('#tmp_customize_condition_body').length > 0
            self.template = Handlebars.compile $('#tmp_customize_condition_body').html()
    render: (obj)->
        self = this

        self.$el.html self.template {
            datas: obj || ccfs.toJSON()
        }
        return this
    events: {
        'change #allSelected': 'allSelected'
    }
    allSelected: (e)->
        e.preventDefault()
        self = this
        $this = $(e.currentTarget)
        checked = $this.attr 'checked'
        self.$el.find('input:checkbox').attr 'checked', !!checked
}

CcfContentView = Backbone.View.extend {
    el: '.customize_condition_fields_content',
    _is_dirty_read: false, #默认不保存
    template: null
    initialize: ()->
        self = this
        if $('#tmp_customize_condition_content').length > 0
            self.template = Handlebars.compile $('#tmp_customize_condition_content').html()
    render: (obj)->
        self = this

        #回显
        selected = $('#customize_condition_fields').val()
        selectedArr = []
        if customizeField.is_json_string(selected) && JSON.parse(selected)
            selectedArr = JSON.parse(selected)
            _.each selectedArr, (x)->
                if x && x._id
                    x.value = (x.value + '' == 'true')
        self.$el.html self.template {
            customize_condition_fields: obj || selectedArr
        }
        return this
    events: {
        'keyup #search_key': 'search'
        'change input'     : (e)->
            self = this
            self._is_dirty_read = true

            $this = $(e.target)
            _id = $this.data 'id'
            isChecked = $this.is(':checked')

            conds = customizeConditionField.condition()
            _.each conds, (x)->
                if x && x._id == _id
                    x.value = isChecked
            customizeConditionField.condition conds
    }
}

_spcfv = new Spcfv()
_spcfvs = new Spcfvs()
_ccfView = new CcfView()
_ccfContentView = new CcfContentView()
###
Systemprocesscustomizefield
###
_spcf = []
_customize_form = null
formBody = null
this.customizeField = {
    ###
    获取系统流程的自定义信息
    ###
    getCustomizeFiledInfo    : (cb)->
        async.parallel {
            customize: (cb)-> #获得自定义字段数据
                pd = $('#customize_pd').val() #获取process_define
                pi = $('#customize_pi').val() #获取process_instance
                $.get '/admin/wf/process_visual_define/customize_bb/' + pd + '/' + pi, (data)->
                    cb(null, data)
            }, (err, result)->
                if err
                    cb(err, null)
                    return
                ###
                if result.customize && _.isArray(result.customize.spcf) && result.customize.spcf.length > 0
                    _spcf = result.customize.spcf
                ###
                if result.customize && _.isArray(result.customize.spcfv) && result.customize.spcfv.length > 0
                    #_spcfvs.set result.customize.spcfv
                    _spcfvs.remove _spcfvs.models
                    _.each result.customize.spcfv, (y, index)->
                        _spcfvs.add y
                        console.log('index:', index)
                        if y && _.isObject(y.field) && y.field._id
                            x = _spcfvs.at(_spcfvs.length - 1)
                            value = x.get 'field'
                            x.set 'field', value._id
                            _spcf.push value
                            if !_customize_form
                                _customize_form = y.customize_form

                    _.each result.customize.spcf, (x)->
                        flag = _.find _spcf, (y)->
                            return if(x && y && y._id == x._id) then true else false

                        if !flag
                            _spcf.push x
                else
                    if result.customize && result.customize.customize_form
                        _customize_form = result.customize.customize_form
                if result.customize && _.isArray(result.customize.spcf) && result.customize.spcf.length > 0
                    _spcf = result.customize.spcf
                    _.each _spcf, (x)->
                        flag = _.find _spcfvs.toJSON(), (y)->
                            if y
                                if _.isObject(y.field)
                                    _id = y.field._id
                                else
                                    _id = y.field
                            return x && y && x._id == _id
                        if !flag
                            _spcfvs.add {
                                field: x._id
                                pi: $('#customize_pi').val()
                                value: ''
                                values: [],
                                customize_form: _customize_form
                            }
                ###_.each _spcf, (x)->
                    flag = _.find _spcfvs.toJSON(), (y)->
                        if y
                            if _.isObject(y.field)
                                _id = y.field._id
                            else
                                _id = y.field
                        return x && y && x._id == _id
                    if !flag
                        _spcfvs.add {
                            field: x._id
                            pi: $('#customize_pi').val()
                            value: ''
                            values: []
                        }###
                cb(err, result)
                ###
                formBodyView.render()###
    ###
    验证自定义字段
    ###
    validate_form_data       : ()->
        self = this
        ret = {
            pass: true,
            errs: []
        }
        _.each _spcf, (x) ->
            flag = self.get_field x
            #检查必输项
            if flag
                flag_id = flag.field
                #is_disable = $('#' + flag_id).attr('disabled')
                is_disable = self.field_is_disabled x
                if !is_disable
                    if x.cat != 'label' && x.require #设定为必输的
                        if !flag.value && (!_.isArray(flag.values) || _.compact(flag.values).length < 1)
                            ret.pass = false
                            ret.errs.push('[' + x.title + ']不能为空')
                        else if (x.ctype == 'cascade' && _.isArray(x.cascade_options) && x.cascade_options.length > 0)
                            values = _.compact flag.values
                            cascade_options = x.cascade_options

                            child = _.reduce(values, (mem, value)->
                                if mem
                                    return _.find(mem, (c)-> c?.name == value)?.children
                                return null
                            , cascade_options[0].children)

                            if _.isArray(child) && child.length > 0
                                ret.pass = false
                                ret.errs.push('[' + x.title + ']请选择完整')
                    #检查数据类型
                    if x.cat == 'num'
                        regexp_num = /^(-)?[0-9\.]*$/;
                        if !regexp_num.test(flag.value) && (x.require || flag.value) #如果数字字段填了或者是必填的,则进行验证;反之不进行校验
                            ret.pass = false
                            ret.errs.push('[' + x.title + ']不是有效的数字')
                    #else if (x.cat == 'date')
        return ret
    validate_table_form_data :(field, data)-> #验证表格的单行数据
        ret = {
            pass: true,
            errs: []
        }
        _.each field.columns,
            (x, index)->
                if x.show
                    #检查必输项
                    if x.require #设定为必输的
                        if !data[index]
                            ret.pass = false
                            ret.errs.push('[' + x.title + ']不能为空')
                    #检查数据类型
                    if x.cat == 'num'
                        regexp_num = /^(-)?[0-9\.]*$/
                        if data[index] && !regexp_num.test(data[index])
                            ret.pass = false;
                            ret.errs.push('[' + x.title + ']不是有效的数字')
                    #else if (x.cat == 'date'

        return ret
    ###
    保存自定义字段的值(Systemprocesscustomizefieldvalue)
    ###
    save_customize_form_data : (callback)->
        self = this

        vr = self.validate_form_data()
        if !vr.pass
            if !($('#attach_to_sign').val() && $('#is_sign_editable').val() == 'true') #会签可编辑
                return callback(vr.errs.join('\n'), null)
        async.times _spcfvs.length, (n, next)->
            tmp = _spcfvs.at n
            if tmp.get('_is_dirty_read')
                tmp.save().done(()->
                    tmp.set('_is_dirty_read', false)
                    next(null, null)
                ).fail((err)->
                    next(err, null)
                )
            else
                next(null, null)
        , (err, result)->
            if (err)
                callback(err, null)
            else
                callback(null, null)
    ###
    暂存自定义字段的值(Systemprocesscustomizefieldvalue)
    ###
    setField                 : (field, value, key)->
        flag = _.find _spcfvs.models, (y)->
            if y && y.attributes
                if _.isObject y.attributes.field
                    _id = y.attributes.field._id
                else
                    _id = y.attributes.field
            return field && y && field._id == _id
        if flag
            if !flag.field_name  #保存field_name
                flag.set('field_name', field.title)
            if !key
                if arguments.length == 1
                    flag.set field
                else
                    flag.set 'value', value
            else
                flag.set key, value
            ###
            有修改,做标记,才保存
            ###
            flag.set '_is_dirty_read', true
    ###
    根据row,col,获得流程的自定义字段
    ###
    get_field2               : (row, col) ->
        return _.find _spcf, (x)->
            return x.row == row && x.col == col;
    ###
    根据spcf,获取流程的自定义字段
    ###
    get_field                : (field) ->
        flag = _.find _spcfvs.toJSON(), (y)->
            if y
                if _.isObject y.field
                    _id = y.field._id
                else
                    _id = y.field
            return field && y && field._id == _id
        return flag
    get_field2ById            : (field_id) ->
        return _.find _spcf, (x)->
            return x._id == field_id;
    get_fieldById            : (field_id) ->
        flag = _.find _spcfvs.toJSON(), (y)->
            if y
                if _.isObject y.field
                    _id = y.field._id
                else
                    _id = y.field
            return y && field_id == _id
        return flag
    is_json_string           : (string)-> #判断是否是json数据
        flag = false
        try
            JSON.parse string
            flag = true
        catch e
            flag = false
        finally
            return flag

    getView                  : (option)->
        initView option
        return formBody
    getSpcf                  : ()->
        return _spcf
    getSpcfvs         : ()->
        return _spcfvs
    getCustomizeForm         : ()->
        return _customize_form
    field_is_disabled: (field)-> #判断当前的任务节点是否能进行编辑
        is_disabled = true
        if field
            td_id = $('#customize_td').val()
            task_editable = _.find field.task_editable, (x)->
                return x.td == td_id
            is_disabled = if (task_editable && task_editable.flag) then false else true
        return is_disabled
}
this.customizeConditionField = {
    fetch: (done)->
        ccfs.fetch()
            .done ->
                console.log ccfs.length
                if ccfs.length > 0
                    $('.customize_condition_fields').show()
                    #回显
                    selected = $('#customize_condition_fields').val()
                    if customizeField.is_json_string(selected) && JSON.parse(selected)
                        selectedArr = JSON.parse(selected)
                        _.each selectedArr, (x)->
                            if x && x._id
                                x.value = x.value + "" == "true"
                    _ccfContentView.render(selectedArr)
                if typeof done == 'function'
                    done null, null
            .fail (err)->
                console.log err
                if typeof done == 'function'
                    done err, null
    select_ccf: ()-> #选择自定义条件字段(只适用于转正流程)
        self = this
        async.series([
            (done)->
                if ccfs.length < 1
                    self.fetch done
                else
                    done(null, null)
        ], (err, result)->
            if err
                console.log err
            else
                _ccfView.render()
                $('#ihModalCCF').modal 'show'
        )
    search: (value)->
        reg = /./;
        reg.compile(value);

        _.each ccfs.toJSON(), (x)->
            if reg.test x.condition_name
                _ccfView.$el.find('tr[data-id="' + x._id + '"]').show()
            else
                _ccfView.$el.find('tr[data-id="' + x._id + '"]').hide()
    condition: (customize_condition_fields)->
        if arguments.length > 0 #set
            $('#customize_condition_fields').val JSON.stringify customize_condition_fields
        else
            selectedArr = []
            selected = $('#customize_condition_fields').val()
            if customizeField.is_json_string(selected) && JSON.parse(selected)
                selectedArr = JSON.parse(selected)
            return selectedArr
    addCondition: (done)->
        self = this
        ids = []
        _ccfView.$el.find('input:checked').each ()->
            id = $(this).data 'id'
            if id
                ids.push id

        _ccfs = _.chain(ccfs.models).filter((x)->
           return _.contains(ids, x.id)
        ).map((x)->
            return x.toJSON()
        ).value()

        customize_condition_fields = self.condition()
        if _.isArray(customize_condition_fields) && customize_condition_fields.length > 0
            _.each customize_condition_fields, (x)->
                if x && x.value + '' == 'true'
                    flag = _.find _ccfs, (y)->
                        return y && y._id == x._id

                    if flag
                        flag.value = true
        self.condition _ccfs

        _ccfContentView.render _ccfs
        _ccfContentView._is_dirty_read = true
        #$('#customize_condition_fields').val JSON.stringify _ccfs
        if typeof done == 'function'
            done null, ids
    saveCondition: (done)->
        async.series([
            (cb)->
                #有修改了才保存
                if _ccfContentView && _ccfContentView._is_dirty_read
                    selected = $('#customize_condition_fields').val()
                    if customizeField.is_json_string(selected) && JSON.parse(selected)
                        selectedArr = JSON.parse(selected)
                        _.each selectedArr, (x)->
                            if x && x._id
                                x.block = x.block + 'true' == 'true'
                                x.value = !!_ccfContentView.$el.find('input[data-id="' + x._id + '"]').attr 'checked'
                        cb null, selectedArr
                    else
                        cb null, null
                else
                    cb null, null
        ],
        (err, result)->
            _ccfContentView._is_dirty_read = false
            selectedArr = result[0]
            if selectedArr
                $.ajax({
                    type: 'post',
                    url: '/admin/wf/universal/save_customize_condition_fields',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({
                        pi: $('#customize_pi').val()
                        customize_condition_fields: selectedArr
                    })
                })
                .done ()->
                    if typeof done == 'function'
                        done null, null
                .fail (err)->
                    if typeof done == 'function'
                        done err, null
            else
                if typeof done == 'function'
                    done null, null
        )
}
initView = (option)->
    _.extend(formBodyViewOption, option)
    FormBody = Backbone.View.extend(formBodyViewOption)
    formBody = new FormBody()


treeListUtil = (->
    _getMaxLevel = (datas)-> #获得最大层级树
        inner = (data, level)->
            maxLevel = -1
            if _.isArray(data.children) && data.children.length > 0
                for child in data.children
                    maxLevel = level + 1
                    finalLevel = inner(child, level+1)
                    if finalLevel > maxLevel
                        maxLevel = finalLevel
            return maxLevel
        maxLevel = -1
        for data in datas
            finalLevel = inner(data, 1)
            if finalLevel == 3
                maxLevel = 3
                break
            else if finalLevel > maxLevel
                maxLevel = finalLevel
        return maxLevel

    _fillData = (datas)->
        maxLevel = _getMaxLevel datas

        for ele, j in datas
            if ele
                context = ele.children
                for i in [1..maxLevel-1]
                    if context && (!_.isArray(context.children) || !context.children.length)
                        context.children = [{
                            name: '无',
                            children: []
                        }]
                    else
                        _.each context, (x)->
                            if x && (!_.isArray(x.children) || !x.children.length)
                                x.children = [{
                                    name: '无',
                                    children: []
                                }]

    ###_getSelect = (array, id)->
        val = []
        if array.length >= 1
            val.push $('#' + id + ' > li').eq(array[0]).children('span').text()

        if array.length >= 2
            tmp = ''
            if $('#' + id + ' > li').eq(array[0]).find('ul li').eq(array[1]).find('ul li').length < 1
                tmp = $('#' + id + ' > li').eq(array[0]).find('ul li').eq(array[1]).text()
                val.push tmp
            else
                tmp = $('#' + id + ' > li').eq(array[0]).find('ul li').eq(array[1]).children('span').text()
                val.push(tmp)

        if array.length >= 3
            tmp = $('#' + id + ' > li').eq(array[0]).find('ul li').eq(array[1]).find('ul li').eq(array[2]).text()
            if tmp
                val.push(tmp)
        return val.join('-')###

    genSelect = (options)->
        str = ''
        ###inner = (data)->
            for ele, index in data
                if ele
                    children = ele.children
                    if _.isArray(children) && children.length > 0
                        str += '<li><span>' + ele.name + '</span><ul>'
                        _.each children, (val, index)->
                            str += "<li>" + val.name + "</li>"
                            inner val.children
                        str += '</ul></li>'
                    else
                        str += '<li><span>' + ele.name + '</span></li>'###

        inner = (data)->
            children = data.children
            if _.isArray(children) && children.length > 0
                str += '<li><span>' + data.name + '</span><ul>'
                _.each children, (val, index)->
                    #str += "<li>" + val.name + "</li>"
                    inner val
                str += '</ul></li>'
            else
                str += '<li><span>' + data.name + '</span></li>'

        if _.isArray(options) && options.length > 0
            _fillData options[0].children
            for ele, index in options[0].children
                if ele
                    inner ele
            return str
        else
            return null


    _default_option = {
        theme: 'default'
        display: 'bubble'
        lang: 'zh'
        cancelText: null
        setText: '确定'
        placeholder: '选择'
        headerText: (valueText)->
            return "选择"
        ###formatResult: (array)->
            return _getSelect(array, null)###
    }

    return {
        init: (id, data, option)->
            self = this
            str = genSelect(data)
            _default_option.formatResult = (array)->
                #return _getSelect(array, id)
                newValues = self.getValues2 array, data
                if _.isArray(newValues)
                    return newValues.join '-'
                return ''
            _default_option.onSelect = (valueText, inst)->
                value = inst.getArrayVal()
                #val = inst.getVal()

                value = self.getValues2 value, data
                if _.isArray value
                    val = value.join '-'
                else
                    val = ''
                field = customizeField.get_field2ById id
                if field
                    customizeField.setField field, val
                    customizeField.setField field, value, 'values'

            if $('#' + id).data('disabled')
                _default_option.disabled = true

            defaultOption = _.extend(_default_option, option)
            $("##{id}").html(str)

            $("##{id}").mobiscroll().treelist(defaultOption)
        ,
        ###
        转成下标回显
        ###
        getValues: (values, data)->
            tmp = []
            flag = data?[0]
            for value,i in values
                if flag && _.isArray(flag.children) && flag.children.length > 0
                    names = _.map flag.children, (x)->
                        return x && x.name
                    _index = _.indexOf names, values[i]
                    if !!~_index
                        tmp.push _index
                        flag = flag.children[_index]
                    else
                        break
                else
                    break
            return tmp
        ###
        转成具体内容
        ###
        getValues2: (values, data)->
            tmp = []
            flag = data?[0]
            for value,i in values
                _index = Number value
                if flag && _.isArray(flag.children) && flag.children.length > _index && flag.children[_index]
                    tmp.push flag.children[_index].name
                    flag = flag.children[_index]
                else
                    break
            return tmp
        getInst: (id)->
            return $(id).mobiscroll('getInst')
    }
)()

cxSelectUtil = (->
    _getMaxLevel = (datas)-> #获得最大层级树
        inner = (data, level)->
            maxLevel = -1
            if _.isArray(data.children) && data.children.length > 0
                for child in data.children
                    if maxLevel < level + 1
                        maxLevel = level + 1
                    finalLevel = inner(child, level+1)
                    if finalLevel > maxLevel
                        maxLevel = finalLevel
            return maxLevel
        maxLevel = -1
        for data in datas
            finalLevel = inner(data, 1)
            if finalLevel == 3
                maxLevel = 3
                break
            else if finalLevel > maxLevel
                maxLevel = finalLevel
        return maxLevel

    return {
        ###
        生成下拉框
        ###
        genSelect: (field)->
            retStr = ''

            if field && _.isArray(field.cascade_options) && field.cascade_options.length > 0
                depth = _getMaxLevel field.cascade_options[0].children
                _id = field._id
                if depth > 0
                    width = Math.floor(100 / depth)
                    fieldValue = customizeField.get_field field
                    values = fieldValue.values

                    disabled = cxSelectUtil.isDisabled field

                    for i in [0..(depth-1)]
                        attrs = ' data-row="' + field.row + '" data-col="' + field.col + '" style="width: ' + width + '%" '

                        if _.isArray(values) && values.length > i
                            attrs += ' data-value="' + values[i] + '" '
                            retStr += '<select class="' + _id + '_' + (i + 1) + '" ' + attrs + ' ' + disabled + '><option>' + values[i] + '</option></select>'
                        else
                            retStr += '<select class="' + _id + '_' + (i + 1) + '" ' + attrs + ' ' + disabled + '></select>'

            return retStr
        genClassName: (field)->
            retArr = []

            if field && _.isArray(field.cascade_options) && field.cascade_options.length > 0
                depth = _getMaxLevel field.cascade_options[0].children
                _id = field._id
                if depth > 0
                    for i in [0..(depth-1)]
                        retArr.push _id + '_' + (i+1)
            return retArr
        getValue: (field)->
            ret = []
            _id = field._id
            $("##{_id} select").each (index)->
                #ret.push if _.isNull($(this).val()) then '' else $(this).val()
                ret.push if !$(this).val() then '' else $(this).val()
                ###$this = $(this)
                val = $this.val()
                if val
                    ret.push val
                else if $this.children('option').length > 1
                    option2 = $this.children('option').eq(1)
                    option2.attr 'selected', true
                    # ret.push option2.text().trim()
                    setTimeout ()-> $this.trigger 'change', 0
                ###
            return ret
        isDisabled: (field)->
            if $('#attach_to_sign').val() #会签可编辑
                if $('#is_sign_editable').val() == 'true'
                    return ''
                else
                    return 'disabled'
            td_id = $('#customize_td').val()
            #判断当前的任务节点是否能进行编辑
            task_editable = _.find field.task_editable, (x)->
                return x.td == td_id
            return if (task_editable && task_editable.flag) then '' else 'disabled'
        isShow: (field)->
            td_id = $('#customize_td').val()
            if !td_id
                history_tasks = $('#history_tasks').val()
                aa_login_user = $('#aa_login_user').val()
                if customizeField.is_json_string(history_tasks) && _.isArray(JSON.parse(history_tasks))
                    history_tasks = JSON.parse(history_tasks)
                    indexs = [history_tasks.length-1..0]
                    for i in indexs by 1
                        x = history_tasks[i]
                        if x
                            _user_id = if x.user && x.user._id then x.user._id else x.user
                            if _user_id == aa_login_user
                                td_id = x.task_define
                                break;
                    if !td_id && _.isArray(history_tasks) && history_tasks.length > 0 #默认是流程发起人
                        td_id = if history_tasks[0] then history_tasks[0]._id else null

            #判断当前的任务节点是否能进行编辑
            task_editable = _.find field.task_editable, (x)->
                return x.td == td_id
            return if (task_editable && task_editable.visible != undefined && !task_editable.flag && !task_editable.visible) then false else true
    }
)()
##与表格有关开始
startWith = (str1, str2)->
    re = /./
    re.compile('^' + str2)
    return re.test(str1)

commafy = (num, fp)-> #转换为千分位显示
    fp = fp || 0
    if _.isNumber(num) && fp >= 0
        num = num.toFixed(fp) + ""
        re = /(-?\d+)(\d{3})/
        while re.test(num)
            num = num.replace(re, "$1,$2");
    return num

apply_formula = (field, data)-> #计算formula的值
    regexp_num = /^(-)?[0-9\.]*$/
    _.each field.columns, (x, index)->
        if x.cat == 'num' && x.formula
            formula = x.formula;
            operands = x.formula.match(/\{\d\}/g)
            _.each operands, (p)->
                idx = parseInt(p.replace(/\{|\}/g, '')) - 1 #获取到数据的index
                idx_data = data[idx]
                if idx_data == '' || !regexp_num.test(idx_data) #如果没写或者不是数字，则给0
                    idx_data = 0;
                formula = formula.replace(p, idx_data)
            val = 0
            try
                val = eval(formula)
            catch e
                val = 0

            try
                val = val.toFixed(x.decimal_digits);
            catch e
                console.log(e)
            data[index] = val + ''

tmp_form_table_form_cal = (render_data)-> #公式计算
    field = render_data.field
    pos = -1;
    _.each render_data.field.columns, (column, index)->
        if column.show
            if field
                pos++
                data = field.values
                row = field.row
                col = field.col
                inputs = $('#table_form_' + row + '-' + col).find("input,select,textarea")
                data = render_data.data
                data_row = render_data.index
                data_col = index
                value = if(data && data[data_col]) then data[data_col] else '' #字段里的值
                inputs.eq(pos).val(value)
##与表格有关结束
if $("#tmp_form_table").length > 0
    window.tmp_form_table = Handlebars.compile $("#tmp_form_table").html()
if $("#tmp_form_table_form").length > 0
    window.tmp_form_table_form = Handlebars.compile $("#tmp_form_table_form").html()
if $("#reprint_layout3").length > 0
    reprint_layout3 = Handlebars.compile($("#reprint_layout3").html())
if $("#reprint_layout4").length > 0
    reprint_layout4 = Handlebars.compile($("#reprint_layout4").html())
if $("#tmp_form_table_print").length > 0
  tmp_form_table_print = Handlebars.compile($("#tmp_form_table_print").html())

(->
    Handlebars.registerHelper 'hasLabel', (row, col, options)->
        field = customizeField.get_field2 row, col
        if field && !_.contains(['label'], field.cat)
            options.fn(this)
        else
            options.inverse(this)

    Handlebars.registerHelper 'labelWidth', (row, col, colspan)->
        field = customizeField.get_field2 row, col
        if !field
          return
        if _.contains(['label'], field.cat)
          return if colspan then 'span10' else 'span5'
        else
          return if colspan then 'span8' else 'span3'

    Handlebars.registerHelper 'renderFieldTitle', (row, col)->
        field = customizeField.get_field2 row, col
        if field && !_.contains(['label'], field.cat)
            ret = []
            if field.require
                ret.push('<span class="text-error">* </span>')
            ret.push('<span>')
            ret.push(field.title)
            ret.push('</span>')
            return ret.join ''
        else
            return ''

    Handlebars.registerHelper 'renderFieldElement', (row, col)->
        field = customizeField.get_field2(row, col)
        spcfvs = customizeField.getSpcfvs()
        if field
            flag = _.find spcfvs.toJSON(), (y)->
                if y
                    if _.isObject y.field
                        _id = y.field._id
                    else
                        _id = y.field
                return field && y && field._id == _id

            multiple = field.multiple
            common_attr = []
            common_attr.push('placeholder="' + field.title + '"')
            common_attr.push('data-row="' + field.row + '"')
            common_attr.push('data-col="' + field.col + '"')
            if field.require
                common_attr.push('required')
            if multiple
                common_attr.push('multiple')
            ca_str = common_attr.join(' ')
            value = if flag then flag.value else '' #字段里的值


            disabled = cxSelectUtil.isDisabled field
            ret = []
            if field.cat == 'str'
                if field.ctype == 'input'
                    ret.push('<input id="' + field._id + '" style="width:90%" type="text" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
                else if field.ctype == 'textarea'
                    ret.push('<textarea id="' + field._id + '" style="width:90%" ' + ca_str + ' ' + disabled + '>' + value + '</textarea>')
                else if field.ctype == 'select'
                    if multiple
                        ret.push('<select id="' + field._id + '" class="chzn-select" data-placeholder="--请选择--" style="width:225px;" ' + ca_str + ' ' + disabled + '>')
                    else
                        ret.push('<select id="' + field._id + '" style="width:90%" ' + ca_str + ' ' + disabled + '>');
                        ret.push('<option value="">--请选择--</opton>');
                    _.each field.options, (x)->
                        _values = if _.isArray(value) then value else (if value then value.split(',') else [])
                        bol = _.contains(_values, x)
                        if bol
                            ret.push('<option value="' + x + '" selected>' + x + '</opton>');
                        else
                            ret.push('<option value="' + x + '">' + x + '</opton>');
                    ret.push('</select>')
                else if field.ctype == 'cascade'
                    ret.push('<div id="' + field._id + '" style="width:90%" class="cascade_field" type="text">' + cxSelectUtil.genSelect(field) + '</div>')
            else if field.cat == 'num'
                ret.push('<input id="' + field._id + '" style="width:90%" type="number" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
            else if field.cat == 'date'
                ret.push('<input id="' + field._id + '" style="width:90%" class="date_field" type="text" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
            else if field.cat == 'time'
                ret.push('<input id="' + field._id + '" style="width:90%" class="time_field" type="text" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
            else if field.cat == 'datetime'
                ret.push('<input id="' + field._id + '" style="width:90%" class="datetime_field" type="text" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
            else if startWith(field.cat, 'table')
                ###
                将values添加到field中
                ###
                table_render_data = _.extend(field, {
                    values: flag.values
                })
                table_render_data.disabled = disabled
                ret.push(window.tmp_form_table(table_render_data)) #也要渲染value， disabled
            else if field.cat == 'label'
              ret.push('<div style="white-space: normal;word-wrap: break-word;width:90%;padding: 10px;font-size:11px;font-family:PingFangSC-Regular;color:rgba(153,153,153,1);border:1px solid rgba(213,238,237,1);border-radius:8px;background:rgba(242,248,247,1);">' + (field.desc || '').replace(/\n/g, '<br>') + '</div>')
            return ret.join('')
        else
            return ''
    ##表格有关的开始
    Handlebars.registerHelper 'renderFieldTitleForTable', (field)->
        if field
            ret = []
            if field.require
                ret.push('<span class="text-error">* </span>')
            ret.push('<span>')
            ret.push(field.title)
            ret.push('</span>')
            return ret.join('')
        else
            return ''

    Handlebars.registerHelper 'renderFieldElementForTable', (field, row, col, data, data_row, data_col)->
        if field
            common_attr = []
            common_attr.push('placeholder="' + field.title + '"')
            common_attr.push('data-row="' + row + '"')
            common_attr.push('data-col="' + col + '"')
            common_attr.push('data-data_row="' + data_row + '"')
            common_attr.push('data-data_col="' + data_col + '"')
            if field.require
                common_attr.push('required')

            ca_str = common_attr.join(' ');
            value = if(data && data[data_col]) then data[data_col] else '' #字段里的值
            ret = []
            if field.cat == 'str'
                if field.ctype == 'input'
                    ret.push('<input style="width:90%" type="text" ' + ca_str + ' value="' + value + '">')
                else if field.ctype == 'textarea'
                    ret.push('<textarea style="width:90%" ' + ca_str + '>' + value + '</textarea>')
                else if field.ctype == 'select'
                    ret.push('<select style="width:90%" ' + ca_str + '>')
                    _.each field.options, (x)->
                        if value == x
                            ret.push('<option value="' + x + '" selected>' + x + '</opton>')
                        else
                            ret.push('<option value="' + x + '">' + x + '</opton>')
                    ret.push('</select>')
            else if field.cat == 'num'
                if field.formula
                    ca_str += ' disabled'
                ret.push('<input style="width:90%" type="text" ' + ca_str + ' value="' + value + '">')
            else if field.cat == 'date'
                ret.push('<input style="width:90%" class="date_field" type="text" ' + ca_str + ' value="' + value + '">')
            else if field.cat == 'time'
                ret.push('<input style="width:90%" class="time_field" type="text" ' + ca_str + ' value="' + value + '">')
            else if field.cat == 'datetime'
                ret.push('<input style="width:90%" class="datetime_field" type="text" ' + ca_str + ' value="' + value + '">')
            return ret.join('')
        else
            return ''

    Handlebars.registerHelper 'getTdStyleByCat', (cat)->
        if cat == 'num'
            return 'text-align:right'
        else if cat == 'date'
            return 'text-align:center'

    Handlebars.registerHelper 'eq', (data1, data2, options)->
        if data1 == data2
            return options.fn(this)
        else
            return options.inverse(this)

    Handlebars.registerHelper 'getTableCellValue', (data_row, col, decimal_digits, thousands)->
        ret = ''
        if _.isObject(data_row)
            ret = data_row[col]
            if decimal_digits #处理小数位数
                ret = $.sprintf("%0." + decimal_digits + "f", ret)
            if thousands #转换千分位显示
                ret = commafy(ret)
        return ret;

    Handlebars.registerHelper 'sum', (data, col, decimal_digits, thousands)->
        sum = 0
        if _.isArray(data)
            data = _.compact(data)
            _.each data, (x)->
                tmp = parseFloat(x[col])
                if _.isNaN(tmp)
                    tmp = 0
                sum += tmp

        if decimal_digits #处理小数位数
            sum = $.sprintf("%0." + decimal_digits + "f", sum)
        if thousands #转换千分位显示
            sum = commafy(sum)
        return sum
    #打印自定义内容的表格title,去掉了*号
    Handlebars.registerHelper 'renderFieldTitlePrint', (row, col)->
        field = customizeField.get_field2(row, col)
        if field
            return field.title
        else
            return '备注'
    #打印自定义内容的非表格内容
    Handlebars.registerHelper 'renderFieldElementPrint', (row, col)->
        field = customizeField.get_field2(row, col)
        spcfvs = customizeField.getSpcfvs()
        if field
            flag = _.find spcfvs.toJSON(), (y)->
                if y
                    if _.isObject y.field
                        _id = y.field._id
                    else
                        _id = y.field
                return field && y && field._id == _id
            value = if flag then flag.value else ''

            ret = []
            if field.cat == 'str'
                if field.ctype == 'input'
                    ret.push(value)
                else if field.ctype == 'textarea'
                    ret.push(value)
                else if field.ctype == 'select'
                    ret.push(value)
                else if field.cat == 'num'
                    ret.push(value)
                else if field.cat == 'date'
                    ret.push(value)
                else if field.cat == 'time'
                    ret.push(value)
                else if field.cat == 'datetime'
                    ret.push(value)
                else if field.ctype == 'cascade'
                    ret.push(flag.value)
                else
                    ret.push('')
            else if field.cat == 'num'
                ret.push(value)
            else if field.cat == 'date'
                ret.push(value)
            else if field.cat == 'time'
                ret.push(value)
            else if field.cat == 'datetime'
                ret.push(value)
            else if startWith field.cat, 'table'
                ret.push('见下表')
            return ret.join('')
        else
            return ''
    #打印表格自定义内容表格部分整体
    Handlebars.registerHelper 'renderFieldTablePrint', (row, col)->
        field = customizeField.get_field2(row, col)
        spcfvs = customizeField.getSpcfvs()
        ret = []
        if field
            flag = _.find spcfvs.toJSON(), (y)->
                if y
                    if _.isObject(y.field)
                      _id = y.field._id;
                    else
                      _id = y.field
                return field && y && field._id == _id

            value = if flag then flag.value else ''
            if startWith(field.cat, 'table')
                table_render_data = _.extend(field, {
                    values: flag.values
                });
                #打印表头
                ret.push('<h4>' + field.title + '</h4>');
                ret.push(tmp_form_table_print(table_render_data));
            return ret.join('')
        else
            return ''
    #打印表格自定义内容表格部分title中去掉*
    Handlebars.registerHelper 'renderFieldTitleForTablePrint', (field)->
        if field
            return field.title
        else
            return ''

    Handlebars.registerHelper 'plus1', (data)->
        return if _.isNumber(data) then (data + 1) else ''
    ##表格有关的结束
    Handlebars.registerHelper 'toISODate', (date)->
        return moment(date).format('YYYY-MM-DD')
    Handlebars.registerHelper 'add', (data, inc)->
        return data + inc
    Handlebars.registerHelper 'condition_field_is_selected', (_id, options)->
        conds = customizeConditionField.condition()
        flag = _.find conds, (x)->
            return x && x._id == _id
        return if flag then options.fn(this) else options.inverse(this)

    Handlebars.registerHelper 'checkin_is_checked', (checkin_id, options)->
        related_checkin = $('#related_checkin').val()
        related_checkin = if related_checkin then related_checkin.split(',') else []
        if _.contains(related_checkin, checkin_id)
            return options.fn(this)
        else
            return options.inverse(this)
)()

deepClone = (obj)->
    switch typeof obj
        when 'undefined' then break;
        when 'string'   then o = obj + ''
        when 'number'   then o = obj - 0
        when 'boolean'  then o = obj
        when 'object'
            if obj == null
                o = null
            else
                if obj instanceof Array
                    o = []
                    for ele in obj
                        o.push deepClone ele
                else
                    o = {}
                    for k, v of obj
                        o[k] = deepClone v
            break;
        else
            o = obj
    return o
