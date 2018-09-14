types = ['tp']
capitalize_first_letter = (string)-> #//首字母大写
	if string && string.length > 0
		return string[0].toUpperCase() + string.substring(1)
	return string

for type in types
	((type)->
		window[type + 'Util'] = ((context)->
			_c_f_l = capitalize_first_letter(type)
			_tp = null
			_tb = null
			_is_show_add_project = -1
			tmpl = Handlebars.compile($('#tmp_' + type).html())
			tp_detail_tmpl = Handlebars.compile($('#tmp_' + type + '_detail').html())

			_render_tp_detail = (tp)-> #渲染任务/项目详情信息
				if tp
					is_related_tp = $("#is_related_" + type).val()
					$('#related_' + is_related_tp).val(tp._id)
				content = tp_detail_tmpl {
					is_related_tp: if tp then is_related_tp else null
					tp: tp
				}
				$('#show_' + type + '_container').html(content)
				context[type + 'Util'].is_start_user (err, result)->
			        if result
			            $('.' + type + '_select').show()
			return {
				getTp: (done)-> #获得任务/项目数据
			        _type = $('#is_related_' + type).val()

			        if type == 'checkin'
			        	if typeof get_draw_item == 'function'
			        	    items = get_draw_item()

			        	    if _.isArray(items) && items.length > 0 && moment(items[0].start_date + ' ' + items[0].time_zone_s).isValid() && moment(items[items.length - 1].end_date + ' ' + items[items.length - 1].time_zone_e).isValid()
			        	        start = moment(items[0].start_date + ' ' + items[0].time_zone_s, 'YYYY-MM-DD HH:mm');
			        	        end = moment(items[items.length - 1].end_date + ' ' + items[items.length - 1].time_zone_e, 'YYYY-MM-DD HH:mm');
			        	        $.post('/wxapp/007/checkin/list_do_new', {
			        	            people_list: [$('#people_id').val()],
			        	            start_date: start.toDate().getTime(),
			        	            end_date: end.toDate().getTime(),
			        	        }).done((data)-> #获取外勤签到信息
			        	            _tp = data
			        	            if typeof done == 'function'
			        	                done(null, _tp)
			        	        ).fail((err)->
			        	            if typeof done == 'function'
			        	                done(err, _tp)
			        	        )
			        	    else
			        	    	if typeof done == 'function'
			        	        done(null, null)
			        	else
			        	    if typeof done == 'function'
			        	        done(null, null)
			       	else if type == 'tp'
				        if _tp
				            if typeof done == 'function'
				                return done(null, _tp)
				            else
				                return _tp
				        if _type == 'task'
				        	console.log 'task'
				        else #默认是项目
				            $.get('/admin/pm/coll_project/bb_limit').done((data)->
				                _tp = data
				                if typeof done == 'function'
				                    done null, _tp
				            ).fail((err)->
				                if typeof done == 'function'
				                    done err, _tp
				            )
				selectTp: ()-> #选择项目
					self = this
					self.getTp((err, datas)->
						if err
							show_notify_msg(err, 'ERR')
							return
						content = tmpl({
							datas: datas
						})
						$('#tbl' + _c_f_l).html(content)

						if !$.fn.DataTable.fnIsDataTable($('#tbl' + _c_f_l)[0])
							_tb = $('#tbl' + _c_f_l).dataTable({
								#"sDom": "<'row-fluid table_top_bar'<'span12'<'to_hide_phone' f>>>t<'row-fluid control-group full top' <'span4 to_hide_tablet'l><'span8 pagination'p>>",
								"aaSorting": [
									[0, "asc"],
								],
								"bSort": false,
								"bPaginate": false,
								"sPaginationType": "full_numbers",
								"bStateSave": true,
								"sPagicostcenterType": "full_numbers",
								"bAutoWidth": false,
								"bJQueryUI": false,
								#"aoColumns": dontSortContact,
								"oLanguage": {
									"sUrl": if (i18n.lng() == 'zh') then "/pagejs/dataTables.chinese.json" else ""
								},
								"fnInitComplete": (oSettings, json)->
									$(".chzn-select, .dataTables_length select").chosen({
										disable_search_threshold: 10
									})
									$('.dataTables_info').hide()
									document.getElementById('tbl' + _c_f_l + '_wrapper').removeChild $('#tbl' + _c_f_l + '_wrapper')[0].childNodes[0]
									$('#tbl' + _c_f_l).next().remove()
								"fnDrawCallback": (oSettings)->
								"fnFooterCallback": (nFoot)->,
								"aLengthMenu": [
									[1, 50, 100, -1],
									[1, 50, 100, "全部"]
								],
								"iDisplayLength": 100,
							});
						$('#ihModal' + _c_f_l).modal('show')
					)
				getTb: ()-> #获得datatable对象
					return _tb
				findById: (_id)->
			        return _.find _tp, (x)->
			            return x && x._id == _id
				setTp: (tp)-> #设置task or project的值
					_render_tp_detail tp
				saveTp: (cb)-> #保存任务/项目和流程的关联关系
					tp_id = null
					is_related_tp = $('#is_related_' + type).val()
					pi = $('#customize_pi').val()
					tp_id = $('#related_' + is_related_tp).val()

					if !pi && window.pi && window.pi.get
						pi = window.pi.get('_id')
					async.series [
						(done) ->
							if type == 'checkin'
								if tp_id
									$.post('/admin/wf/process_instance/' + type + '/save', {
										pi: pi,
										checkin: tp_id,
									})
									.done((data)->
										done(null, null)
									)
									.fail((err)->
										done(err, null)
									)
								else
			            		    done(null, null)
							else 
								if _.contains(['task', 'project'], is_related_tp)
									if tp_id
										$.post('/admin/wf/process_instance/tp/save', {
											pi: pi,
											is_related_tp: is_related_tp,
											tp: tp_id,
										})
										.done((data)->
											done(null, null)
										)
										.fail((err)->
											done(err, null)
										)
									else
										done(null, null)
								else
									done(null, null)
					],
					(err, result)->
						if typeof cb == 'function'
							cb err, result
				firstRender: ()->
					self = this
					is_related_tp = $('#is_related_' + type).val()
					tp_id = null
					tp = $('#related_' + is_related_tp).val()
					
					if tp
						if tp._id
							_render_tp_detail(tp)
						else
							self.is_start_user (err, result)->
								if result
									self.getTp(()->
										data = _.find(_tp, (x)->
											return x && x._id == tp
										)
										if data
											_render_tp_detail data
										else
											if type == 'checkin'
												$.get('/wxapp/007/checkin/detail_do/' + tp).done((data)->
													_tp = [data]
													_render_tp_detail(data || null)
												).fail((err)->
													_render_tp_detail(null)
												)
											else 
												$.get('/admin/pm/coll_' + (is_related_tp) + '/bb/' + tp).done((data)->
													_tp = [data]
													_render_tp_detail(data || null)
												).fail((err)->
													_render_tp_detail(null)
												)
									)
								else
									if type == 'checkin'
										$.get('/wxapp/007/checkin/detail_do/' + tp).done((data)->
											_tp = [data]
											_render_tp_detail(data || null)
										).fail((err)->
											_render_tp_detail(null)
										)
									else 
										$.get('/admin/pm/coll_' + (is_related_tp) + '/bb/' + tp).done((data)->
											_tp = [data]
											_render_tp_detail(data || null)
										).fail((err)->
											_render_tp_detail(null)
										)
					else
						_render_tp_detail null
				is_start_user: (yesCb)-> #判断是否是流程发起人
					is_callback = typeof yesCb == 'function'
					if _is_show_add_project == -1
						if window.pi && window.pi.get && window.pi.get('start_user') #定义流程
							login_user = $('#login_user').val()
							start_user = if window.pi.get('start_user') && window.pi.get('start_user')._id then window.pi.get('start_user')._id else null
							
							if login_user == start_user
								_is_show_add_project = true
							else
								_is_show_add_project = false
							
							if typeof yesCb == 'function'
								yesCb(null, _is_show_add_project)
						else
							$.post('/admin/wf/process_instance/is_start_user', {
								pi: $('#customize_pi').val()
							})
							.done((data)->
								if data && data.is_start_user
									_is_show_add_project = true
								else
									_is_show_add_project = false
								if is_callback
									yesCb(null, _is_show_add_project)
							)
							.fail((err)->
								if is_callback
									yesCb(null, false)
							)
					else
						if is_callback
							yesCb(null, _is_show_add_project)
				tp_is_selected: ()-> #项目/任务,是否未选择
			        is_related_tp = $('#is_related_' + type).val()
			        flag = true
			        if is_related_tp
			            if !$('#related_' + is_related_tp).val() #如果没填
			                flag = false
			        return flag
			}
		)(window)
	)(type)