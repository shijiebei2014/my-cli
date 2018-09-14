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

CcfView = Backbone.View.extend {
    el: '.conditions_container',
    template: null
    initialize: ()->
        self = this
        if $('#tmp_customize_condition_body').length > 0
            self.template = wfCommon.templateFunc 'tmp_customize_condition_body'

        $('.popup.popup-conditions')
            .on 'click', '.sure', (e)->
                e.preventDefault()

                customizeConditionField.addCondition (err, ids)->
                    console.log 'ids:' + ids
                    myApp.closeModal('.popup-conditions')
    render: (obj)->
        self = this

        self.$el.html self.template {
            datas: obj || ccfs.toJSON()
        }
        return this
}

CcfContentView = Backbone.View.extend {
    el: '.customize_condition_fields',
    _is_dirty_read: false, #默认不保存
    template: null
    initialize: ()->
        self = this
        self.template = wfCommon.templateFunc 'tmp_customize_condition_content'
    render: (obj)->
        self = this
        if !self.template
            return this
        #回显
        selectedArr = customizeConditionField.condition()
        _.each selectedArr, (x)->
            if x && x._id
                x.value = (x.value + '' == 'true')
        self.$el.html self.template {
            customize_condition_fields: obj || []
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
        'click #btn_select_full_member_condition': 'select_full_member_condition',
    }
    select_full_member_condition: (event)-> #选择转正条件
        event.preventDefault()
        customizeConditionField.select_ccf()
}

ccfs = new CustomizeConditionFields()
_ccfView = new CcfView()
_ccfContentView = null

formBodyViewOption = {
    el: '',
    template: null,
    curField: null,
    initialize: ()->
        this.bindEvents()
    render: ()->
        self = this

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
        self.$el.html self.template render_data

        _.each render_data.customize_fields, (x)->
            if x
                #$('#customize_form_body').find('.item-content[data-row="' + x.row + '"][data-col="' + x.col + '"]').show()

                ### td_id = $('#customize_td').val()
                task_editable = _.find x.task_editable, (y)->
                    return y.td == td_id
                if task_editable && task_editable.visible != undefined && !task_editable.flag && !task_editable.visible
                    console.log('')
                else
                    $('#customize_form_body').find('.item-content[data-row="' + x.row + '"][data-col="' + x.col + '"]').show() ###
                if x && cxSelectUtil.isShow(x)
                    $('#customize_form_body').find('.item-content[data-row="' + x.row + '"][data-col="' + x.col + '"]').show()
                    $('#customize_form_body').find('.item-content[data-row="' + x.row + '"][data-col="' + x.col + '"]').show()
                    #$('#customize_form_body').find('label[data-row="' + x.row + '"][data-col="' + x.col + '"]').show()
                    #$('#customize_form_body').find('div[data-row="' + x.row + '"][data-col="' + x.col + '"]').show()
                else
                    $('#customize_form_body').find('.item-content[data-row="' + x.row + '"][data-col="' + x.col + '"]').hide()
                    $('#customize_form_body').find('.item-content[data-row="' + x.row + '"][data-col="' + x.col + '"]').hide()
        format_date 'time'
        format_date 'date'
        format_date 'datetime'
        ###self.$el.find(".date_field").mobiscroll().calendar {
            theme: 'mobiscroll'
            lang: 'zh'
            display: 'bubble'
            swipeDirection: 'vertical'
            controls: ['calendar']
            startYear: 2014
            endYear: 2030
            mode: 'mixed'
            dateFormat: 'yy-mm-dd'
        }
        self.$el.find(".time_field").mobiscroll().calendar {
            theme: 'mobiscroll'
            lang: 'zh'
            display: 'bubble'
            swipeDirection: 'vertical'
            controls: ['time']
            startYear: 2014
            endYear: 2030
            mode: 'mixed'
            dateFormat: 'yy-mm-dd'
            steps: {
                minute: 5,
                zeroBased: true
            }
        }
        self.$el.find(".datetime_field").mobiscroll().calendar {
            theme: 'mobiscroll'
            lang: 'zh'
            display: 'bubble'
            swipeDirection: 'vertical'
            controls: ['calendar', 'time']
            startYear: 2014
            endYear: 2030
            mode: 'mixed'
            dateFormat: 'yy-mm-dd'
            steps: {
                minute: 5,
                zeroBased: true
            }
        }###

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
        return this
    events: {
        'change input,textarea,select': 'changeField'
        'click .cascade_field': 'select_cascade'
        'click .multiple_field': 'select_multiple'
        'click .btn_add_tr_data': (event)-> #增加一行表格数据
            event.preventDefault()
            $this = $(event.currentTarget)
            this.curField = null
            row = $this.data('row')
            col = $this.data('col')
            field = customizeField.get_field2(row, col)

            if field
                if !field.values
                    field.values = []
                field.values.push({})
                customizeField.setField field, field.values, 'values'
                render_data = {
                    field: field,
                    data: {},
                    index: field.values.length - 1,
                }
                customizeField.save_customize_form_data ->
                    tableRenderUtil.render_table_trans render_data
                , {
                    skip_validate: true
                }

        'click .btn_edit_tr_data': (event)-> #编辑一行表格数据
            event.preventDefault()
            self = this

            $this = $(event.currentTarget)
            row = $this.data('row')
            col = $this.data('col')
            index = $this.data('index')
            field = customizeField.get_field2(row, col)
            data = field.values[index]
            self.curField = deepClone(field); #记录当前的数据
            if field
                render_data = {
                    field: field,
                    data: data,
                    index: index
                }
                customizeField.save_customize_form_data ->
                    tableRenderUtil.render_table_trans(render_data)
                , {
                    skip_validate: true
                }
        'click .btn_remove_tr_data': (event)-> #删除一行表格数据
            event.preventDefault()
            self = this
            $this = $(event.currentTarget)
            row = $this.data('row')
            col = $this.data('col')
            index = $this.data('index')
            field = customizeField.get_field2(row, col)
            data = field.values[index]
            if field# && data
                myApp.confirm("确认要删除吗?", ()->
                    field.values.splice(index, 1)
                    customizeField.setField field, field.values, 'values'
                    self.render()
                )
    }
    changeField: (e, no_op)->
        e.preventDefault();
        if no_op
            return
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
                customizeField.setField(field, value)
            else if tableRenderUtil.startWith(field.cat, 'table') #对于表格内部的数据的变化，直接修改数据，等到用户点击“保存”的时候再render
                field.values[data_row][data_col] = value
                customizeField.setField(field, field.values, 'values')
                #是否设定了公式需要计算的
                if field.columns[data_col].cat == 'num'
                    data = field.values[data_row]
                    tableRenderUtil.apply_formula(field, data)
                    render_data = {
                        field: field,
                        data: data,
                        index: data_row
                    }
                    tableRenderUtil.render_table_trans(render_data)
    select_cascade: (e)->
        e.preventDefault()

        $this = $(e.target)
        id = $this.prop "id"
        field = customizeField.get_field2ById id
        fieldValue = customizeField.get_fieldById id
        if field?.cascade_options?[0]?.children && _.isArray(field.cascade_options[0].children)
            cascadeTmpl = Template7.templates.tmp_cascadeTmpl

            datas = field.cascade_options[0].children

            obj = _.extend {
                datas: datas
            }, {
                curPosition: 0
                selectedText: if fieldValue.value then fieldValue.value else ''
                dispaly: if fieldValue.values?.length > 0 then fieldValue.values[0] else ''
            }

            cascadeView.render obj
            cascadeView.hash = {}
            cascadeView.datas = obj.datas
            cascadeView.field = field
            ###changeEvent = (e)->
                e.preventDefault()
                curPosition = Number($('#curPosition').val())
                pos = Number($(e.target).data('pos'))

                selectedText = []
                hash[curPosition] = pos
                next_datas = []

                for i in [0..curPosition]
                    tmp_pos = hash[i]

                    if i == 0
                        selectedText[i] = datas[tmp_pos].name
                        if _.isArray(datas[tmp_pos].children) && datas[tmp_pos].children.length > 0
                            next_datas = datas[tmp_pos].children
                        else
                            next_datas = []
                    else
                        selectedText[i] = next_datas[tmp_pos].name
                        if next_datas[tmp_pos] && _.isArray(next_datas[tmp_pos].children) && next_datas[tmp_pos].children.length > 0
                            next_datas = next_datas[tmp_pos].children
                        else
                            next_datas = []

                if _.isArray(next_datas) && next_datas.length > 0
                    $('.cascade_container').html cascadeTmpl _.extend {
                        datas: next_datas
                    }, {
                        curPosition: if curPosition >= 2 then 2 else ++curPosition,
                        selectedText:  selectedText.join '-'
                    }
                else
                    $('#selected_title').text selectedText.join '-'

                $('.popup.popup-cascade-tmpl .pre').show()
                $('.cascade_container input[type=radio]').change (e)->
                    changeEvent e

            $('.cascade_container input[type=radio]').change (e)->
                changeEvent e###

            myApp.popup('.popup-cascade-tmpl')
    select_multiple: (e)->
        e.preventDefault()

        $this = $(e.target)
        id = $this.prop "id"
        tmp = customizeField.getSpcf()
        flag = _.find tmp, (x)->
            return x && x._id == id
        if flag
            field = customizeField.get_field flag
            flag.value = if _.isArray(field.value) then field.value else (if field.value && field.value.split(',') then field.value.split(',') else [])
            flag.options = if _.isArray(flag.options) then flag.options else []
            multipleView.render flag

            _.each flag.options, (x, index)->
                if _.contains(flag.value, x)
                    $this = $('.multiple_select_li').eq(index)
                    $this.css { #选中
                        'background-color': '#2e8ded',
                        color: 'white',
                    }
                else
                    $this.eq(index).css { #未选中
                        'background-color': 'white',
                        color: 'black'
                    }
            myApp.popup '.popup-multiple-tmpl'
    bindEvents: ()->
        self = this
        $("#form_table")
            .off 'click', '.btn_cancel_tr_data'
            .on 'click', '.btn_cancel_tr_data', (event)-> #取消新建或编辑
                event.preventDefault()
                console.log('.btn_cancel_tr_data')
                if self.curField
                    customizeField.setField2(self.curField)
                    self.curField = null
                else
                    $this = $(this);
                    row = $this.data('row');
                    col = $this.data('col');
                    index = $this.data('index');
                    field = customizeField.get_field2(row, col);
                    field.values.splice(index, 1);
                    customizeField.setField(field, field.values, 'values')
                self.render()
            .off 'click', '.btn_save_tr_data'
            .on 'click', '.btn_save_tr_data', (event)-> #保存一行表格数据
                event.preventDefault()
                _self = this
                _self.curField = null
                $this = $(_self)
                row = $this.data('row')
                col = $this.data('col')
                index = $this.data('index')
                $("#form_table select").trigger 'change'
                # $("#form_table input,textarea,select").trigger('change')
                #做表单验证
                field = customizeField.get_field2(row, col)
                data = field.values[index]
                vr = customizeField.validate_table_form_data(field, data)
                if vr.pass
                    customizeField.save_single_customize_form_data(field, ()->
                        myApp.closeModal('#form_table')
                        self.render()
                        #window.location.reload()
                    )
                else
                    myApp.alert(vr.errs.join('\n'))
            .off 'change', 'input,textarea,select'
            .on 'change', 'input,textarea,select', (e, isChange)->
                event.preventDefault();

                $this = $(this);
                row = $this.data('row');
                col = $this.data('col');
                data_row = $this.data('data_row');
                data_col = $this.data('data_col');
                value = $this.val();
                field = customizeField.get_field2(row, col);
                if field
                    if _.contains(['date', 'time', 'datetime'], field.cat) && !isChange
                        return ;
                    if field.cat == 'str' || field.cat == 'num' || field.cat == 'date' || field.cat == 'time' || field.cat == 'datetime'
                        #field['data'] = value;
                        customizeField.setField(field, value)
                        self.render()
                    else if tableRenderUtil.startWith(field.cat, 'table') #对于表格内部的数据的变化，直接修改数据，等到用户点击“保存”的时候再render
                        if _.contains(['date', 'time', 'datetime'], field.columns[data_col].cat)
                            if isChange
                                if !_.isObject(field.values[data_row])
                                    field.values[data_row] = {}
                                field.values[data_row][data_col] = value
                        else
                            if !_.isObject(field.values[data_row])
                                field.values[data_row] = {}
                            field.values[data_row][data_col] = value
                        customizeField.setField(field, field.values, 'values')
                        #是否设定了公式需要计算的
                        if field.columns[data_col].cat == 'num'
                            data = field.values[data_row]
                            tableRenderUtil.apply_formula(field, data)
                            render_data = {
                                field: field,
                                data: data,
                                index: data_row
                            }
                            tableRenderUtil.render_table_trans(render_data)
}

MultipleView = Backbone.View.extend {
    el: '.multiple_container',
    field: {value: [], options: []}

    initialize: ()->
        self = this
        $('.popup-multiple-tmpl')
            .on 'click', '.sure', (e)->
                e.preventDefault();

                $('#' + self.field._id).html self.field.value.join '<br>'
                customizeField.setField self.field, self.field.value.join(','), 'value'
                $('#' + self.field._id).trigger('change', true)
                #layer.closeAll()
                myApp.closeModal '.popup-multiple-tmpl'
            .on 'blur', '.search_key', (e)-> #筛选
                e.preventDefault()

                $this = $(e.target)
                val = $this.val()

                $('.multiple_item').each ()->
                    text = $(this).text()

                    re = /./
                    re.compile(val)

                    if !re.test(text)
                        $(this).parent().parent().parent().hide()
                    else
                        $(this).parent().parent().parent().show()
    render: (obj)->
        self = this
        multipleTmpl = Template7.templates.tmp_multipleTmpl

        self.field = if _.isObject(obj) then obj else {value: [], options: []}
        obj.data = obj.value
        self.$el.html(multipleTmpl(obj))
        _.each self.field.options, (x, index)->
            if _.contains(self.field.value, x)
                $('.multiple_option').eq(index).css({ #选中
                    'background-color': '#2e8ded',
                    color: 'white',
                })
            else
                $('.multiple_option').eq(index).css({ #未选中
                    'background-color': 'white',
                    color: 'black'
                })
        return this
    events: {
        'click li': 'selectEvent'
    },
    selectEvent: (e)->
        event.preventDefault()

        self = this

        pos = Number($(e.target).data('pos'))
        value = self.field.value
        if self.field.options.length > pos
            _pos = _.indexOf(self.field.value, self.field.options[pos])
            if !~_pos #等于-1
                value.push(self.field.options[pos])
            else
                self.field.value.splice(_pos, 1)

        self.render self.field
}

CascadeView = Backbone.View.extend {
    el: '.cascade_container'
    field: {}
    datas: []
    hash: {}
    initialize: ()->
        self = this
        $('.popup.popup-cascade-tmpl')
            .on 'click', '.pre', (e)->
                e.preventDefault()

                curPosition = Number($('.cascade_container #curPosition').val())
                console.log(curPosition)


                for i in [curPosition..2]
                    delete self.hash[i]
                --curPosition

                ret = self.getNext_datasByCurPosition curPosition, -1, self.datas
                next_datas = ret.next_datas
                selectedText = ret.selectedText

                self.render _.extend {
                    datas: next_datas
                }, {
                    curPosition: if curPosition < 0 then 0 else curPosition,
                    selectedText:  selectedText.join '/'
                }
                if curPosition > 0
                    $('.popup.popup-cascade-tmpl .pre').show()
                #$('.cascade_container #curPosition').val(curPosition)
            .on 'click', '.sure', (e)->
                e.preventDefault()

                values = []
                next = self.datas
                for key, value of self.hash
                    if next[value]
                        values.push next[value].name
                        if next[value].children?.length
                            next = next[value].children
                        else
                            break;
                    else
                        break

                console.log(values)
                customizeField.setField self.field, values.join('/')
                customizeField.setField self.field, values, 'values'
                $('#' + self.field._id).val values.join '/'

                myApp.closeModal '.popup-cascade-tmpl'
                #$('.cascade_container #curPosition').val(curPosition)
            .on 'blur', '.search_key', (e)-> #筛选
                e.preventDefault()

                $this = $(e.target)
                val = $this.val()

                self.$el.find('.cascade_item').each ()->
                    text = $(this).text()

                    re = /./
                    re.compile val

                    if !re.test text
                        $(this).parent().parent().parent().hide()
                    else
                        $(this).parent().parent().parent().show()
    render: (obj)->
        cascadeTmpl = Template7.templates.tmp_cascadeTmpl

        $('.popup.popup-cascade-tmpl .pre').hide()
        $('.cascade_container').html cascadeTmpl obj

        return this
    events: {
        'change input[type=radio]': 'changeEvent'
    }
    ###
    pos
        > 0:表示向后选
        < 0:表示向前退
    ###
    getNext_datasByCurPosition: (curPosition, pos, datas)->
        self = this

        selectedText = []
        if pos >= 0
            self.hash[curPosition] = pos
        next_datas = []

        if pos < 0 && curPosition == 0 #直接返回第一层数据
            return {
                next_datas: datas
                selectedText: [datas[0].name]
            }

        for i in [0..curPosition]
            tmp_pos = self.hash[i]

            if i == 0
                selectedText[i] = datas[tmp_pos].name

                if _.isArray(datas[tmp_pos].children) && datas[tmp_pos].children.length > 0
                    next_datas = datas[tmp_pos].children
                else
                    next_datas = []
            else
                selectedText[i] = next_datas[tmp_pos].name
                ###
                往前退,最后一步不要跳
                ###
                if i == curPosition && pos < 0
                    continue
                else
                    if next_datas[tmp_pos] && _.isArray(next_datas[tmp_pos].children) && next_datas[tmp_pos].children.length > 0
                        next_datas = next_datas[tmp_pos].children
                    else
                        next_datas = []
        return {
            next_datas: next_datas
            selectedText: selectedText
        }
    changeEvent: (e)->
        e.preventDefault()

        self = this
        datas = self.datas
        curPosition = Number($('#curPosition').val())
        pos = Number($(e.target).data('pos'))

        ret = self.getNext_datasByCurPosition curPosition, pos, datas
        next_datas = ret.next_datas
        selectedText = ret.selectedText

        if _.isArray(next_datas) && next_datas.length > 0
            self.render _.extend {
                datas: next_datas
            }, {
                curPosition: if curPosition >= 2 then 2 else ++curPosition,
                selectedText:  selectedText.join '/'
            }
        else
            $('#selected_title').text selectedText.join '/'

        $('.popup.popup-cascade-tmpl .pre').show()
}

_spcfv = new Spcfv()
_spcfvs = new Spcfvs()
cascadeView = new CascadeView()
multipleView = new MultipleView()
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
        if _spcf.length > 0 #如果已经有了,就不重复加载
            return cb(null, null)
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
                ###
                先清空,后添加
                ###
                _spcfvs.remove(_spcfvs.models)
                _spcf = []
                if result.customize && _.isArray(result.customize.spcfv) && result.customize.spcfv.length > 0
                    #_spcfvs.set result.customize.spcfv
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
                else
                    if result.customize && result.customize.customize_form
                        _customize_form = result.customize.customize_form

                if result.customize && _.isArray(result.customize.spcf) && result.customize.spcf.length > 0
                    _spcf = result.customize.spcf
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
                    if x != 'label' && x.require #设定为必输的
                        if !flag.value && (!_.isArray(flag.values) || flag.values.length < 1)
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
    保存单个
    ###
    save_single_customize_form_data: (field, callback)->
        self = this

        flag = _.find _spcfvs.models, (x)->
            if x.get('field') == field._id
                return true
            return false

        if flag
            flag.set('values', field.values)
            flag.save().always(callback)
        else
            if typeof callback == 'function'
                callback null, null
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
    setField2                 : (field)->
        flag = _.find _spcfvs.models, (y)->
            if y && y.attributes
                if _.isObject y.attributes.field
                    _id = y.attributes.field._id
                else
                    _id = y.attributes.field
            return field && y && field._id == _id
        if flag
            flag.set field
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
    get_fieldById            : (field_id) ->
        flag = _.find _spcfvs.toJSON(), (y)->
            if y
                if _.isObject y.field
                    _id = y.field._id
                else
                    _id = y.field
            return y && field_id == _id
        return flag
    get_field2ById            : (field_id) ->
        flag = _.find _spcf, (y)->
            return y && y._id == field_id
        return flag
    get_fieldModel           : (field) ->
        flag = _.find _spcfvs.models, (y)->
            if y
                if _.isObject y.get('field')
                    _id = y.get('field')._id
                else
                    _id = y.get('field')
            return field && y && field._id == _id
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
                    selectedArr = customizeConditionField.condition()
                    _.each selectedArr, (x)->
                        if x && x._id
                            x.value = x.value + "" == "true"
                    if !_ccfContentView
                        _ccfContentView = new CcfContentView()
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
                myApp.popup('.popup-conditions')
                #$('#ihModalCCF').modal 'show'
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
            if wfCommon.wf_view.data?.ti?.process_instance
                wfCommon.wf_view.data.ti.process_instance.customize_condition_fields = customize_condition_fields
        else
            return wfCommon.wf_view.data?.ti?.process_instance.customize_condition_fields || []
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
        if typeof done == 'function'
            done null, ids
    saveCondition: (done)->
        if !_ccfContentView
            if typeof done == 'function'
               done null, null
            return
        async.series([
            (cb)->
                #有修改了才保存
                if _ccfContentView._is_dirty_read
                    cb null, customizeConditionField.condition() || []
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
_cascadeUtil = ()->
    return {
        _getMaxLevel: (datas)-> #获得最大层级树
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
        initLevelData: (datas)-> #获得
            self = this

            ret = []
            maxLevel = self._getMaxLevel datas #获得最大层级树

            for i in [0..(maxLevel-1)] #初始化数据
                ret[i] = ['无']

            ret[0] = _.chain(datas).map((x)-> #获得第一层数据
                return x && x.name
            ).compact().value()


            for i in [0..(maxLevel-1)]
                if i == 0
                    if _.isArray(ret[0]) && ret[0].length > 0
                        start = ret[0][0]
                        source = datas
                    else
                        break
                else
                    flag = _.find source, (x)->
                        return x && x.name == start
                    if flag && _.isArray(flag.children) && flag.children.length > 0
                        ret[i] = _.chain(flag.children).map((x)->
                            return x && x.name
                        ).compact().value()

                        if _.isArray(ret[i]) && ret[i].length > 0
                            start = ret[i][0]
                            source = flag
                        else
                            break
                    else
                        break

            return ret
        initCols: (datas)-> #初始化列
            self = this

            cols = []
            levels = self.initLevelData datas
            maxLevel = levels.length

            if maxLevel < 1
                cols.push {
                    values: []
                    cssClass: 'customize_css'
                    textAlign: 'left'
                }
            else if maxLevel == 1
                cols.push {
                    values: levels[0]
                    cssClass: 'customize_css'
                    textAlign: 'left'
                }
            else
                for i in [1..maxLevel]
                    if i == maxLevel
                        cols.push {
                            values: levels[i - 1]
                            cssClass: 'customize_css'
                            textAlign: 'left'
                        }
                    else
                        cols.push {
                            values: levels[i - 1]
                            cssClass: 'customize_css'
                            textAlign: 'left'
                            onChange: ((i)->
                                (picker, value)->
                                    for j in [0..(i-1)]
                                        val = picker.cols[j].value
                                        if j == 0
                                            flag = _.find(datas, (x)->
                                                return x && x.name == val
                                            )
                                        else
                                            if flag
                                                flag = _.find flag.children, (x)->
                                                    return x && x.name == val
                                            else
                                                break
                                    if flag && _.isArray(flag.children) && flag.children.length > 0
                                        level_2 = _.chain(flag.children).map((x)->
                                            return x && x.name
                                        ).compact().value()
                                        if picker.cols[i].replaceValues
                                            if _.isArray(level_2) && level_2.length > 0
                                                picker.cols[i].replaceValues level_2
                                            else
                                                picker.cols[i].replaceValues ['无']
                                        else
                                            if picker.cols[i].replaceValues
                                                picker.cols[i].replaceValues ['无']
                                    else
                                        if picker.cols[i].replaceValues
                                            picker.cols[i].replaceValues ['无']
                                    return
                            )(i)
                        }

            ###if cols.length
                for col in cols
                    col.width = Math.floor(100/cols.length) + '%'###
            return cols
    }
initView = (option)->
    _.extend(formBodyViewOption, option)
    FormBody = Backbone.View.extend(formBodyViewOption)
    formBody = new FormBody()

format_date = (type)-> #初始化日期控件
    initializePicker = (id)->
        new_id = id
        today = getDate(id)
        value = [today.year, today.month, today.date, today.hours, today.minutes]
        cols = [
            # Years
            {
                values: (()->
                    arr = (num for num in [2000..2030])
                    return arr
                )(),
            },
            # Months
            {
                values: ('1 2 3 4 5 6 7 8 9 10 11 12').split(' '),
                displayValues: ('一月 二月 三月 四月 五月 六月 七月 八月 九月 十月 十一月 十二月').split(' '),
                textAlign: 'left'
            },
            # Days
            {
                values: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31],
            },
            # Hours
            {
                values: (()->
                    arr = (num for num in [0..23])
                    return arr
                )(),
            },
            # Divider
            {
                divider: true,
                content: ':'
            },
            # Minutes
            {
                values: (()->
                    arr = (if num < 10 then '0' + num else num for num in [0..59])
                    return arr
                )(),
            }
        ]
        if type == 'date'
            value = [today.year, today.month, today.date]
            cols = [
                # Years
                {
                    values: (()->
                        arr = (num for num in [2000..2030])
                        return arr
                    )(),
                },
                # Months
                {
                    values: ('1 2 3 4 5 6 7 8 9 10 11 12').split(' '),
                    displayValues: ('一月 二月 三月 四月 五月 六月 七月 八月 九月 十月 十一月 十二月').split(' '),
                    textAlign: 'left'
                },
                # Days
                {
                    values: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31],
                }
            ]
        else if type == 'time'
            value = [today.hours, today.minutes]
            cols = [
                # Hours
                {
                    values: (()->
                        arr = (num for num in [0..23])
                        return arr
                    )(),
                },
                # Divider
                {
                    divider: true,
                    content: ':'
                },
                # Minutes
                {
                    values: (()->
                        arr = (if num < 10 then '0' + num else num for num in [0..59])
                        return arr
                    )(),
                }
            ]
        return {
            input: id,
            toolbar: true,
            rotateEffect: true,
            toolbarTemplate: '<div class="toolbar">' +
                '<div class="toolbar-inner">' +
                '<div class="left">' +
                '<a href="#" class="link toolbar-ok-link">确定</a>' +
                '</div>' +
                '<div class="right">' +
                '<a href="#" class="link toolbar-clear-link">清除</a>' +
                '</div>' +
                '<div class="right">' +
                '<a href="#" class="link close-picker">取消</a>' +
                '</div>' +
                '</div>' +
                '</div>',
            onChange: (picker, values, displayValues)->
                console.log 'values:', values
                console.log 'displayValues:', displayValues
                if type != 'time'
                    daysInMonth = moment(values[0] + '-' + values[1], 'YYYY-MM').daysInMonth()
                    col = picker.cols[2]
                    tmp_values = (num for num in [1..daysInMonth])
                    # col.replaceValues(tmp_values, col.displayValues)
                    picker.cols[2].setValue(tmp_values);
            value: value
            onOpen: (picker)->
                picker.container.find('.toolbar-ok-link').click ()-> #点击确定按钮
                    values = picker.value
                    if type == 'datetime'
                        $$(new_id).val values[0] + '/' + pad(values[1]) + '/' + pad(values[2]) + ' ' + pad(values[3]) + ':' + pad(values[4])
                    else if type == 'date'
                        $$(new_id).val values[0] + '/' + pad(values[1]) + '/' + pad(values[2])
                    else if type == 'time'
                        $$(new_id).val values[0] + ':' + pad(values[1])
                    $(new_id).trigger 'change', true
                    picker.close();
                picker.container.find('.toolbar-clear-link').click ()-> #点击清除按钮
                    $$(new_id).val ''
                    $$(picker.input).trigger 'change'
                    picker.close();

                date = getDate new_id
                if type == 'datetime'
                    picker.setValue [date.year, parseInt(date.month), parseInt(date.date), parseInt(date.hours), parseInt(date.minutes)]
                else if type == 'date'
                    picker.setValue [date.year, parseInt(date.month), parseInt(date.date)]
                else if type == 'time'
                    picker.setValue [parseInt(date.hours), pad(parseInt(date.minutes))]

            formatValue: (p, values, displayValues)->
                if type == 'datetime'
                    return values[0] + '-' + pad(values[1]) + '-' + pad(values[2]) + ' ' + pad(values[3]) + ':' + pad(values[4])
                else if type == 'date'
                    return values[0] + '-' + pad(values[1]) + '-' + pad(values[2])
                else if type == 'time'
                    return pad(values[0]) + ':' + pad(values[1])
            cols: cols
        }

    getDate = (id)->
        date = {}
        name = $(id).attr('name')
        val = $(id).val()
        # if wf_view && wf_view.wf_data && wf_view.wf_data.leave && moment(wf_view.wf_data.leave[name]).isValid()
        if val
            format = 'YYYY-MM-DD'
            if type == 'time'
                format = 'HH:mm'
            data = moment(val, format)
            date.year = data.get('year')
            date.month = data.get('month') + 1
            date.date = data.get('date')
            date.hours = data.get('hour')
            date.minutes = data.get('minute')
        else
            today = new Date()
            date.year = today.getFullYear()
            date.month = Number(today.getMonth()) + 1
            date.date = today.getDate()
            date.hours = today.getHours()
            date.minutes = (if today.getMinutes() < 10 then '0' + today.getMinutes() else today.getMinutes())
        return date

    pad = (num)-> #左边补零
        return Array(if 10 > parseInt(num) then (2 - ('' + num).length + 1) else 0).join(0) + num

    $$('.' + type + '_field').each (index)->
        myApp.picker initializePicker "#" + $$(this).attr('id')

window.tableRenderUtil = (->
    return {
        startWith: (str1, str2)->
            re = /./
            re.compile '^' + str2
            return re.test str1
        commafy: (num, fp)-> #转换为千分位显示
            fp = fp || 0
            if _.isNumber(num) && fp >= 0
                num = num.toFixed(fp) + ""
                re = /(-?\d+)(\d{3})/
                while re.test(num)
                    num = num.replace(re, "$1,$2");
            return num
        apply_formula: (field, data)-> #计算formula的值
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
        tmp_form_table_form_cal: (render_data)-> #公式计算
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
        render_table_trans: (render_data)-> #表格明细
            ###
            显示: #form_table
            隐藏: 除#form_table外的
            ###
            if $("#form_table").length > 0
                $("#form_table").html tmp_form_table_form render_data
                $("#form_table input,select,textarea").css {
                    'font-size': '14px'
                }
                $("#form_table select").each ()->
                    $(this).on 'mousedown', =>
                        $(this).focus()
                myApp.popup('#form_table')
                format_date 'date'
               ### $(".form_table").find(".date_field").mobiscroll().calendar {
                    theme: 'mobiscroll',
                    lang: 'zh',
                    display: 'bottom',
                    swipeDirection: 'vertical',
                    controls: ['calendar'],
                    startYear: 2000,
                    endYear: 2030,
                    mode: 'mixed',
                    dateFormat: 'yy-mm-dd'
                }
                ###
    }
)()

deepClone = (obj) ->
    switch (typeof obj)
        when 'undefined'
            break;
        when 'string'
            o = obj + '';
            break;
        when 'number'
            o = obj - 0;
            break;
        when 'boolean'
            o = obj;
            break;
        when 'object'
            if obj == null
                o = null
            else
                if obj instanceof Array
                    o = [];
                    for val in obj
                        o.push deepClone(val)

                else
                    o = {};
                    for k,v of obj
                        o[k] = deepClone(obj[k]);
            break;
        else
            o = obj;
            break;
    return o;

cxSelectUtil = (->
    return {
        isDisabled: (field)->
            if $('#attach_to_sign').val() && $('#is_sign_editable').val() == 'true' #会签可编辑
                return ''
            td_id = $('#customize_td').val()

            task_editable = _.find field.task_editable, (x)->
                return x.td == td_id && x.flag

            if task_editable
                return ''
            else
                return 'disabled'
        isShow: (field)->
            td_id = $('#customize_td').val()
            if !td_id
                history_tasks = if formBodyViewOption.wf_data && _.isArray(formBodyViewOption.wf_data.history_tasks) then formBodyViewOption.wf_data.history_tasks else null
                login_people = $('#login_people').val()
                if _.isArray(history_tasks)
                    indexs = [history_tasks.length-1..0]
                    for i in indexs by 1
                        x = history_tasks[i]
                        if x
                            _people_id = if x.user then (if x.user.people && x.user.people._id then x.user.people._id else x.user.people) else null
                            if _people_id == login_people
                                td_id = x.task_define
                                break;
                    if !td_id && _.isArray(history_tasks) && history_tasks.length > 0 #默认是流程发起人
                        td_id = if history_tasks[0] then history_tasks[0]._id else null
            #判断当前的任务节点是否能进行编辑
            task_editable = _.find field.task_editable, (x)->
                return x.td == td_id
            return if (task_editable && task_editable.visible != undefined && !task_editable.flag && !task_editable.visible) then false else true
        genId: (field)->
            if field
                return field._id
            return ''
    }
)()
