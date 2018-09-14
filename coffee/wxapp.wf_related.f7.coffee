types = ['tp']
_is_show_add_project = -1
capitalize_first_letter = (string)-> #//首字母大写
	if string && string.length > 0
		return string[0].toUpperCase() + string.substring(1)
	return string

for type in types
	((type)->
		window[type + 'Util'] = ((context)->
			_c_f_l = capitalize_first_letter(type)
			_tp = null
			_selected_tp = null
			#_is_show_add_project = -1

			_render_tp_detail = (tp)-> #渲染任务/项目详情信息
				if tp
					is_related_tp = $("#is_related_" + type).val()
					$('#related_' + is_related_tp).val(tp._id)
					_selected_tp = tp._id
				content = commonView[type + '_detail_tmpl'] {
					is_related_tp: if tp then is_related_tp else null
					tp: tp
				}
				$('#' + type + '_form_body').html(content)
				context[type + 'Util'].is_start_user (err, result)->
					if result
						$('.' + type + '_select').show()
			return {
				getTp: (done)-> #获得任务/项目数据
					_type = $('#is_related_' + type).val()

					if type == 'checkin'
						if typeof get_draw_item == 'function'
							items = get_draw_item()

							if _.isArray(items) && items.length > 0 && moment(items[0].start_date).isValid() && moment(items[items.length - 1].end_date).isValid()
								if items[0].is_full_day
									start = moment(items[0].start_date + ' 00:00', 'YYYY-MM-DD HH:mm');
								else
									start = moment(items[0].start_date + ' ' + (if items[0].time_zone_s then items[0].time_zone_s else '00:00'), 'YYYY-MM-DD HH:mm');
								if items[items.length - 1].is_full_day
									end = moment(items[items.length - 1].end_date + ' 23:59', 'YYYY-MM-DD HH:mm');
								else
									end = moment(items[items.length - 1].end_date + ' ' + (if items[items.length - 1].time_zone_e then items[items.length - 1].time_zone_e else : '23:59'), 'YYYY-MM-DD HH:mm');
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
							myApp.alert(err)
							return
						window[type + 'View'].render({
					        datas: datas
					    })
						myApp.popup('.popup-' + type + '-tmpl')
					)
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
					tp = if _selected_tp then _selected_tp else $('#related_' + is_related_tp).val()
					
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
						if typeof yesCb == 'function'
							yesCb(null, _is_show_add_project)
				tp_is_selected: ()-> #项目/任务,是否未选择
					is_related_tp = $('#is_related_' + type).val()
					flag = true
					msg = '请选择'
					if is_related_tp
						if !$('#related_' + is_related_tp).val() #如果没填
							flag = false
							if type == 'tp'
								msg += if is_related_tp == 'task' then '任务' else '项目'	
							else if type =='checkin'
								msg += '外勤签到'
					return {
						status: flag
						msg   : msg  
					}
			}
		)(window)
	)(type)

types = ['checkin']

for type in types
	((type)->
		window[type + 'Util'] = ((context)->
			_c_f_l = capitalize_first_letter(type)
			_tp = null
			_selected_tp = null
			#_is_show_add_project = -1

			_render_tp_detail = (tp)-> #渲染外勤签到信息
				tp = if _.isArray(tp) then tp else []

				is_related_tp = $("#is_related_#{type}").val()
				content = commonView[type + '_detail_tmpl'] {
					is_related_tp: if tp then is_related_tp else null
					tp: tp
				}
				tp = _.chain(tp).map (x)-> 
					return if x then x._id else null
				.compact().value().join(',')
				$("#related_#{type}").val tp
				$("##{type}_form_body").html(content)
				_selected_tp = tp
				context[type + 'Util'].is_start_user (err, result)->
					if result
						$('.' + type + '_select').show()
			return {
				getTp: (done)-> #获得任务/项目数据
					_type = $('#is_related_' + type).val()

					if type == 'checkin'
						if typeof get_draw_item == 'function'
							items = get_draw_item()

							if _.isArray(items) && items.length > 0 && moment(items[0].start_date).isValid() && moment(items[items.length - 1].end_date).isValid()
			        	        #start = moment(items[0].start_date + ' ' + items[0].time_zone_s, 'YYYY-MM-DD HH:mm');
			        	        #end = moment(items[items.length - 1].end_date + ' ' + items[items.length - 1].time_zone_e, 'YYYY-MM-DD HH:mm');
								if items[0].is_full_day
									start = moment(items[0].start_date + ' 00:00', 'YYYY-MM-DD HH:mm');
								else
									start = moment(items[0].start_date + ' ' + (if items[0].time_zone_s then items[0].time_zone_s else "00:00"), 'YYYY-MM-DD HH:mm');
								if items[items.length - 1].is_full_day
									end = moment(items[items.length - 1].end_date + ' 23:59', 'YYYY-MM-DD HH:mm');
								else
									end = moment(items[items.length - 1].end_date + ' ' + (if items[items.length - 1].time_zone_e then items[items.length - 1].time_zone_e else "23:59"), 'YYYY-MM-DD HH:mm');
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
						console.log('其他')
				selectTp: ()-> #选择项目
					self = this
					self.getTp((err, datas)->
						if err
							myApp.alert(err)
							return
						window[type + 'View'].render({
					        datas: datas
					    })
						myApp.popup('.popup-' + type + '-tmpl')
					)
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
					tp_id = if tp_id then tp_id.split(',') else []

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
								done(null, null)
					],
					(err, result)->
						if typeof cb == 'function'
							cb err, result
				firstRender: (param)->
					self = this
					is_related_tp = $('#is_related_' + type).val()
					tp_id = null
					tp = if _selected_tp then _selected_tp else $("#related_#{is_related_tp}").val()
					tp = if tp then tp.split(',') else []
					if tp.length > 0
						self.is_start_user (err, result)->
							if type == 'checkin'
								$.post('/wxapp/007/checkin/details', {
									checkin_ids: tp
								}).done((data)->
									_tp = data
									_render_tp_detail(data || null, param)
								).fail((err)->
									_render_tp_detail(null, param)
								)
							else 
								console.log('其他')
					else
						_render_tp_detail null, param
				is_start_user: (yesCb)-> #判断是否是流程发起人
					is_callback = typeof yesCb == 'function'
					if _is_show_add_project == -1
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
					msg = '请选择'
					if is_related_tp
						if !$('#related_' + is_related_tp).val() #如果没填
							flag = false
							if type == 'tp'
								msg += if is_related_tp == 'task' then '任务' else '项目'	
							else if type =='checkin'
								msg += '外勤签到'
					return {
						status: flag
						msg   : msg  
					}
				set_is_start_user: (val)->
					_is_show_add_project = val			
			}
		)(window)
	)(type)