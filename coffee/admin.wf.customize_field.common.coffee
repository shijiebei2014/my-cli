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

CascadeView = Backbone.View.extend {
    el: '#cascade_list'
    field: {}
    datas: []
    hash: {}
    cascadeTmpl: Handlebars.compile $('#tmp_cascadeTmpl').html()
    initialize: ()->
        self = this
        self.$el.on('click', '.pre', (e)->
            e.preventDefault();
            curPosition = Number $('#demoradio #curPosition').val()
            for i in [curPosition..2]
                delete self.hash[i]
            --curPosition
            ret = self.getNext_datasByCurPosition(curPosition, -1, self.datas)
            next_datas = ret.next_datas
            selectedText = ret.selectedText
            self.render _.extend {
                datas: next_datas
            }, {
                curPosition: if curPosition < 0 then 0 else curPosition
                selectedText: selectedText.join('/')
            }
            if curPosition > 0
                $('#cascade_list .pre').show()
            else
                $('#cascade_list .pre').hide()
        ).on('click', '.sure', (e)->
            e.preventDefault()
            values = [];
            next = self.datas
            for key, value of self.hash
                if next[value]
                    values.push(next[value].name);
                    if next?[value]?.children?.length > 0
                        next = next[value].children;
                    else
                        break
                else
                    break
            self.field.data = values
            $('#' + self.field._id).val values.join '/'
            customizeField.setField self.field, values, 'values'
            customizeField.setField self.field, values.join('/'), 'value'
            layer.closeAll()
        ).on('blur', '.search_key', (e)-> #筛选
            e.preventDefault()

            $this = $(e.target)
            val = $this.val()

            $('#demoradio li').each ()->
                text = $(this).text()

                re = /./
                re.compile val

                if !re.test text
                    $(this).hide()
                else
                    $(this).show()
        )
    render: (obj)->
        self = this

        self.$el.html(self.cascadeTmpl(obj))
        return this
    events: {
        'click li': 'selectEvent'
    },
    ###
    pos
        > 0:表示向后选
        < 0:表示向前退
    ###
    getNext_datasByCurPosition: (curPosition, pos, datas)->
        self = this;
        selectedText = [];
        if pos >= 0
            self.hash[curPosition] = pos;
        next_datas = [];
        if pos < 0 && curPosition == 0
            return {
                next_datas: datas,
                selectedText: [datas[0].name]
            }
        for i in [0..curPosition]
            tmp_pos = self.hash[i];
            if i == 0
                selectedText[i] = datas[tmp_pos].name
                if _.isArray(datas[tmp_pos].children) && datas[tmp_pos].children.length > 0
                    next_datas = datas[tmp_pos].children;
                else
                    next_datas = []
            else
                selectedText[i] = next_datas[tmp_pos].name
                ###
                往前退,最后一步不要跳
                ###
                if i == curPosition && pos < 0
                    continue;
                else
                    if next_datas[tmp_pos] && _.isArray(next_datas[tmp_pos].children) && next_datas[tmp_pos].children.length > 0
                        next_datas = next_datas[tmp_pos].children
                    else
                        next_datas = []
        return {
            next_datas: next_datas,
            selectedText: selectedText
        }
    selectEvent: (e)->
        e.preventDefault()
        self = this
        datas = self.datas
        curPosition = Number $('#curPosition').val()
        pos = Number $(e.target).data('pos')
        ret = self.getNext_datasByCurPosition(curPosition, pos, datas)
        next_datas = ret.next_datas
        selectedText = ret.selectedText
        if _.isArray(next_datas) && next_datas.length > 0
            self.render _.extend {
                datas: next_datas
            }, {
                curPosition: if curPosition >= 2 then 2 else ++curPosition
                selectedText: selectedText.join('/')
            }
        else
            $('#cascade_list #selected_title').text(selectedText.join('/'))
}

MultipleView = Backbone.View.extend {
    el: '#multiple_list',
    field: {value: [], options: []}
    multipleTmpl: if $('#tmp_multipleTmpl').length > 0 then Handlebars.compile($('#tmp_multipleTmpl').html()) else null,
    initialize: ()->
        self = this
        self.$el
            .on 'click', '.sure', (e)->
                e.preventDefault();

                $('#' + self.field._id).html self.field.value.join '<br>'
                #customizeField.setField self.field, self.field.value, 'values'
                customizeField.setField self.field, self.field.value.join(','), 'value'
                $('#' + self.field._id).trigger('change', true)
                layer.closeAll()
            .on 'blur', '.search_key', (e)-> #筛选
                e.preventDefault()

                $this = $(e.target)
                val = $this.val()

                $('#multiplecheckbox li').each ()->
                    text = $(this).text()

                    re = /./
                    re.compile(val)

                    if !re.test(text)
                        $(this).hide()
                    else
                        $(this).show()
    render: (obj)->
        self = this

        self.field = if _.isObject(obj) then obj else {value: [], options: []}
        obj.data = obj.value
        self.$el.html(self.multipleTmpl(obj))

        _.each self.field.options, (x, index)->
            if _.contains(self.field.value, x)
                $('#multiplecheckbox li').eq(index).css({ #选中
                    'background-color': '#2e8ded',
                    color: 'white',
                })
            else
                $('#multiplecheckbox li').eq(index).css({ #未选中
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

formBodyViewOption = {
    el: '',
    template: Handlebars.compile $("#tmp_customize_form_body").html()
    # initialize: ()->
    #     this.bindEvents()
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

        date_fields = self.$el.find(".date_field")
        time_fields = self.$el.find(".time_field")
        datetime_fields = self.$el.find(".datetime_field")
        cascade_fields = self.$el.find ".cascade_field"
        multiple_fields = self.$el.find ".multiple_field"
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
            $('.cascade_field').each ()->
                id = $(this).prop 'id'
                tmp = customizeField.getSpcf()
                flag = _.find tmp, (x)->
                    return x && x._id == id
                val = customizeField.get_fieldById(id)

                if flag
                    data = flag.cascade_options
                    ###treeListUtil.init id, data, {
                        #defaultValue: [0, 0],
                        inputClass: 'form-control',
                        placeholder: '选择' + flag.title,
                        headerText: (valueText)->
                            return "选择" + flag.title
                    }
                    #数据回显
                    if _.isArray(val.values) && val.values.length > 0
                        values = treeListUtil.getValues val.values, data
                        console.log 'values:', values
                        treeListUtil.getInst("##{id}").setArrayVal values, true###
                    #inst = treeListUtil.getInst("##{id}")
                    #inst.setVal(['0', '1'], true)
                    if cxSelectUtil.isDisabled(flag) != 'disabled'
                        $('#' + flag._id).click (e)->
                            datas = data[0].children

                            cascadeView.render _.extend {
                                datas: datas
                            }, {
                                curPosition: 0,
                                selectedText: val.value
                            }

                            cascadeView.hash = {}
                            cascadeView.datas = datas
                            cascadeView.field = flag
                            $('#cascade_list .pre').hide()
                            layer.open({ #弹层显示
                                type: 1,
                                title: false,
                                closeBtn: 0,
                                shadeClose: true,
                                shade: 0.8,
                                area: ['100%', '100%'],
                                content: $('#cascade_list'),
                                btn: ['确定', '取消'],
                                btnAlign: 'c',
                                yes: (index, layero)-> #确定的回调
                                    $('#cascade_list .sure').trigger('click')
                                no: (index)-> #取消的回调
                                success: (layero, index)->
                                    $('.layui-layer-btn a').css {
                                        width: '45%'
                                    }
                            })

        if multiple_fields.length > 0
            $('.multiple_field').each ()->
                id = $(this).prop 'id'
                tmp = customizeField.getSpcf()
                flag = _.find tmp, (x)->
                    return x && x._id == id
                if flag
                    if cxSelectUtil.isDisabled(flag) != 'disabled'
                        $('#' + flag._id).click (e)->
                            field = customizeField.get_field flag

                            flag.value = if _.isArray(field.value) then field.value else (if field.value && field.value.split then field.value.split(',') else [])
                            flag.options = if _.isArray(flag.options) then flag.options else []
                            multipleView.render flag
                            layer.open { #弹层显示
                                type: 1,
                                title: false,
                                closeBtn: 0,
                                shadeClose: true,
                                shade: 0.8,
                                area: ['100%', '100%'],
                                content: $('#multiple_list'),
                                btn: ['确定', '取消'],
                                btnAlign: 'c',
                                yes: (index, layero)-> #确定的回调
                                    $('#multiple_list .sure').trigger('click')
                                no: (index)-> #取消的回调
                                success: (layero, index)->
                                    $('.layui-layer-btn a').css {
                                        width: '45%'
                                    }
                            }
                            return false
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
            #if x
            #    $('#customize_form_body').find('label[data-row="' + x.row + '"][data-col="' + x.col + '"]').show();
            #    return $('#customize_form_body').find('div[data-row="' + x.row + '"][data-col="' + x.col + '"]').show();
            if x && cxSelectUtil.isShow(x)
                $('#customize_form_body').find('#' + x._id).parent().parent().show()
                $('#customize_form_body').find('#' + x._id).parent().parent().show()
                #$('#customize_form_body').find('label[data-row="' + x.row + '"][data-col="' + x.col + '"]').show()
                #$('#customize_form_body').find('div[data-row="' + x.row + '"][data-col="' + x.col + '"]').show()
            else
                $('#customize_form_body').find('#' + x._id).parent().parent().hide()
                $('#customize_form_body').find('#' + x._id).parent().parent().hide()
        return this
    events: {
        'change input,textarea,select': 'changeField'
        'click #btn_add_tr_data': (event)-> #增加一行表格数据
            event.preventDefault()
            $this = $(event.currentTarget)

            row = $this.data('row')
            col = $this.data('col')
            field = customizeField.get_field2(row, col)

            if field
                if !field.values
                    field.values = []
                field.values.push({})
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
            if field && data
                show_confirm "流程", "确认要删除吗？", ()->
                    field.values.splice(index, 1)
                    customizeField.setField field, field.values, 'values'
                    self.render()
    }
    changeField: (e, no_op)->
        e.preventDefault();
        if no_op
            return ;
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
    bindEvents: ()->
        self = this
        $("#form_table")
            # .off 'click', '.btn_save_tr_data'
            .on 'click', '.btn_save_tr_data', (event)-> #保存一行表格数据
                event.preventDefault()
                self = this

                $this = $(self)
                row = $this.data('row')
                col = $this.data('col')
                index = $this.data('index')

                $("#form_table select").trigger('change')
                #做表单验证
                field = customizeField.get_field2(row, col)
                data = field.values[index]
                vr = customizeField.validate_table_form_data(field, data)
                if vr.pass
                    customizeField.save_single_customize_form_data(field, ()->
                        window.location.reload()
                    )
                else
                    show_msg(vr.errs.join('\n'), 'danger', 3)
            # .off 'change', 'input,textarea,select'
            .on 'change', 'input,textarea,select', (e)->
                event.preventDefault();

                $this = $(this);
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
                        self.render()
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
                cb(err, result)
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
                        if !flag.value && (!_.isArray(flag.values) || flag.values.length < 1)
                            ret.pass = false
                            ret.errs.push('[' + x.title + ']不能为空')
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
    save_customize_form_data : (callback, option)->
        self = this
        if !(option && option.skip_validate)
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
    get_fieldModel           : (field) ->
        flag = _.find _spcfvs.models, (y)->
            if y
                if _.isObject y.get('field')
                    _id = y.get('field')._id
                else
                    _id = y.get('field')
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

initView = (option)->
    _.extend(formBodyViewOption, option)
    FormBody = Backbone.View.extend(formBodyViewOption)
    if formBody
      formBody.remove()
      formBody = new FormBody()
    else
      formBody = new FormBody()
      formBody.bindEvents()

cxSelectUtil = (->
    return {
        isDisabled: (field)->
            if $('#attach_to_sign').val() #会签可编辑
                if $('#is_sign_editable').val() == 'true'
                    return ''
                else
                    return 'disabled'
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
            return _getSelect(array, null)
        ,###
        onSelect: (event, inst)->
    }

    return {
        init: (id, data, option)->
            self = this
            str = genSelect(data)
            _default_option.formatResult = (array)->
                newValues = self.getValues2 array, data
                if _.isArray(newValues)
                    return newValues.join '-'
                return ''

            _default_option.onSelect = (event, inst)->
                value = inst.getArrayVal()
                #val = inst.getVal()

                value = self.getValues2 value, data
                if _.isArray value
                    val = value.join '-'
                else
                    val = ''
                #inst.setVal val, true
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
##与表格有关开始

tableRenderUtil = (->
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
                $("#form_table").siblings().hide()

                $("#form_table").html tmp_form_table_form render_data
                #$("#basic_buttons").hide();
                #$("#tbl_info_buttons").show();
                #$("#confirm_trans").hide();
                #$("#promotion_form").hide();
                $("#form_table").show();

                $("#form_table").find(".date_field").mobiscroll().calendar {
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
    }
)()

##与表格有关结束
if $("#tmp_form_table").length > 0
    window.tmp_form_table = Handlebars.compile $("#tmp_form_table").html()
if $("#tmp_form_table_form").length > 0
    window.tmp_form_table_form = Handlebars.compile $("#tmp_form_table_form").html()
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
          return if !colspan then 'span8' else 'span10'
        else
          return if !colspan then 'span3' else 'span5'

    Handlebars.registerHelper 'renderFieldTitle', (row, col)->
        field = customizeField.get_field2 row, col
        fieldModel = customizeField.get_fieldModel(field)
        if field
            ret = []
            if tableRenderUtil.startWith field.cat, 'table'
                #判断当前的任务节点是否能进行编辑
                td_id = $('#customize_td').val()
                task_editable = _.find field.task_editable, (x)->
                    return x.td == td_id
                disabled = if (task_editable && task_editable.flag) then '' else 'disabled'

                ret.push('<li id="info_section" style="background-color: rgba(0,0,0,0.1);" class="list-group-item text-info">');
                ret.push('<i class="fa fa-list"></i>');
                ret.push('<span class="text-danger">* </span>')
                ret.push(field.title)
                if !disabled
                    ret.push('<div style="position:absolute; right:4.5em; top:5px" class="btn-group">')
                    ret.push('<button id="btn_add_tr_data" type="button" class="btn btn-default btn-sm pull-right"  data-row="' + field.row + '" data-col="' + field.col + '">')
                    ret.push('<i class="fa fa-plus"></i>')
                    ret.push('添加明细');
                    ret.push('</button>')
                    ret.push('</div>')

                ret.push('<span class="badge">')
                ret.push(if fieldModel?.get('values') then fieldModel.get('values').length else 0)
                ret.push('</span>')
                ret.push('</li>')
            else
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

            common_attr = []
            common_attr.push('placeholder="' + field.title + '"')
            common_attr.push('data-row="' + field.row + '"')
            common_attr.push('data-col="' + field.col + '"')
            if field.require
                common_attr.push('required')
            ca_str = common_attr.join(' ')
            value = if flag then flag.value else '' #字段里的值

            td_id = $('#customize_td').val()
            #判断当前的任务节点是否能进行编辑
            task_editable = _.find field.task_editable, (x)->
                return x.td == td_id
            disabled = if (task_editable && task_editable.flag) then '' else 'disabled'
            if $('#attach_to_sign').val() #会签可编辑
                if $('#is_sign_editable').val() == 'true'
                    disabled = ''
                else
                    disabled = 'disabled'
            ret = []
            if field.cat == 'str'
                if field.ctype == 'input'
                    ret.push('<input class="form-control" id="' + field._id + '" type="text" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
                else if field.ctype == 'textarea'
                    ret.push('<textarea class="form-control" id="' + field._id + '" ' + ca_str + ' ' + disabled + '>' + value + '</textarea>')
                else if field.ctype == 'select'
                    if field.multiple
                        _arr = (if _.isArray(flag.value) then flag.value else (if flag.value && flag.value.split then flag.value.split(',') else _.compact([flag.value])))
                        _value = _arr.join('<br>')
                        ret.push('<div id="' + field._id + '" class="multiple_field" ' + ca_str + ' style="font-size:14px;color:#666;word-break: break-word;min-height: 30px;border: 1px solid #eee;border-radius: 5px;">' + _value + '</div>');
                    else
                        ret.push('<select class="form-control" id="' + field._id + '" ' + ca_str + ' ' + disabled + '>');
                        ret.push('<option value="">--请选择--</opton>');
                        _.each field.options, (x)->
                            if value == x
                                ret.push('<option value="' + x + '" selected>' + x + '</opton>');
                            else
                                ret.push('<option value="' + x + '">' + x + '</opton>');
                        ret.push('</select>')
                else if field.ctype == 'cascade'
                    ret.push('<input class="form-control cascade_field" id="' + (field._id) + '" type="text" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
                    ###if disabled
                        ret.push '<ul id="' + field._id + '" style="display: none;" class="cascade_field" data-disabled="true"></ul>'
                    else
                        ret.push '<ul id="' + field._id + '" style="display: none;" class="cascade_field"></ul>'###
            else if field.cat == 'num'
                ret.push('<input class="form-control" id="' + field._id + '" type="number" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
            else if field.cat == 'date'
                ret.push('<input class="form-control date_field" id="' + field._id + '" type="text" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
            else if field.cat == 'time'
                ret.push('<input class="form-control time_field" id="' + field._id + '" type="text" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
            else if field.cat == 'datetime'
                ret.push('<input class="form-control datetime_field" id="' + field._id + '" type="text" ' + ca_str + ' value="' + value + '" ' + disabled + '>')
            else if tableRenderUtil.startWith(field.cat, 'table')
                ###
                将values添加到field中
                ###
                table_render_data = _.extend(field, {
                    values: flag.values
                })
                table_render_data.disabled = disabled
                ret.push(window.tmp_form_table(table_render_data)) #也要渲染value， disabled
            else if field.cat == 'label'
               ret.push("<div style='white-space: normal;word-wrap: break-word;padding:5px;background:rgba(242,248,247,1);border-radius:8px;border:1px solid rgba(213,238,237,1);font-size:11px;font-family:PingFangSC-Regular;color:rgba(153,153,153,1);'>" + (field.desc || '').replace(/\n/g, '<br>') + "</div>")
            return ret.join('')
        else
            return ''

    Handlebars.registerHelper 'join', (arr, d)->
        return if _.isArray(arr) then arr.join(d || '') else ''
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
                    ret.push('<input class="form-control" type="text" ' + ca_str + ' value="' + value + '">')
                else if field.ctype == 'textarea'
                    ret.push('<textarea class="form-control" ' + ca_str + '>' + value + '</textarea>')
                else if field.ctype == 'select'
                    ret.push('<select class="form-control" ' + ca_str + '>')
                    _.each field.options, (x)->
                        if value == x
                            ret.push('<option value="' + x + '" selected>' + x + '</opton>')
                        else
                            ret.push('<option value="' + x + '">' + x + '</opton>')
                    ret.push('</select>')
            else if field.cat == 'num'
                if field.formula
                    ca_str += ' disabled'
                ret.push('<input class="form-control" type="text" ' + ca_str + ' value="' + value + '">')
            else if field.cat == 'date'
                ret.push('<input class="form-control date_field" type="text" ' + ca_str + ' value="' + value + '">')
            else if field.cat == 'time'
                ret.push('<input class="form-control time_field" type="text" ' + ca_str + ' value="' + value + '">')
            else if field.cat == 'datetime'
                ret.push('<input class="form-control datetime_field" type="text" ' + ca_str + ' value="' + value + '">')
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
                ret = tableRenderUtil.commafy(ret)
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
            sum = tableRenderUtil.commafy(sum)
        return sum

    Handlebars.registerHelper 'plus1', (data)->
        return if _.isNumber(data) then (data + 1) else ''
    ##表格有关的结束
)()
