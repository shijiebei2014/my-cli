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

			_render_tp_detail = (tp, param)-> #渲染任务/项目详情信息
				tp_detail_tmpl = Handlebars.compile($('#tmp_' + type + '_detail').html())
				if tp
					is_related_tp = $("#is_related_" + type).val()
					$('#related_' + is_related_tp).val(tp._id)
					_selected_tp = tp._id
				content = tp_detail_tmpl {
					is_related_tp: if tp then is_related_tp else null
					tp: tp
				}
				$('#' + type + '_form_body').html(content)
				if param && param.view
					console.log('查看界面')
				else
					context[type + 'Util'].is_start_user (err, result)->
						if result
							$('.' + type + '_select').parent().show()

							$('.' + type + '_select').on('click', (event)->
							    context[type + 'Util'].selectTp()
							)
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
							myApp.alert(err)
							return
						window[type + 'View'].render({
							datas: datas
						})
						layer.open({ #弹层显示
							type: 1,
							title: false,
							closeBtn: 0,
							shadeClose: true,
							shade: 0.8,
							area: ['100%', '80%'],
							content: $('.' + type + '_container'),
							btn: ['确定', '取消'],
							btnAlign: 'c',
							yes: (index, layero)-> #确定的回调
								window[type + 'View'].selectedTp()
							no: (index)-> #取消的回调
							success: (layero, index)->
								$('.layui-layer-btn a').css({
									width: '45%'
								})
						})
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
				firstRender: (param)->
					self = this
					is_related_tp = $('#is_related_' + type).val()
					tp_id = null
					tp = if _selected_tp then _selected_tp else $('#related_' + is_related_tp).val()

					if tp
						if tp._id
							_render_tp_detail(tp, param)
						else
							self.is_start_user (err, result)->
								if result
									self.getTp(()->
										data = _.find(_tp, (x)->
											return x && x._id == tp
										)
										if data
											_render_tp_detail data, param
										else
											if type == 'checkin'
												$.get('/wxapp/007/checkin/detail_do/' + tp).done((data)->
													_tp = [data]
													_render_tp_detail(data || null, param)
												).fail((err)->
													_render_tp_detail(null, param)
												)
											else
												$.get('/admin/pm/coll_' + (is_related_tp) + '/bb/' + tp).done((data)->
													_tp = [data]
													_render_tp_detail(data || null, param)
												).fail((err)->
													_render_tp_detail(null, param)
												)
									)
								else
									if type == 'checkin'
										$.get('/wxapp/007/checkin/detail_do/' + tp).done((data)->
											_tp = [data]
											_render_tp_detail(data || null, param)
										).fail((err)->
											_render_tp_detail(null, param)
										)
									else
										$.get('/admin/pm/coll_' + (is_related_tp) + '/bb/' + tp).done((data)->
											_tp = [data]
											_render_tp_detail(data || null, param)
										).fail((err)->
											_render_tp_detail(null, param)
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


###
多选,checkin
###
types = ['checkin']

for type in types
	((type)->
		window[type + 'Util'] = ((context)->
			_checkin_date = null
			_c_f_l = capitalize_first_letter(type)
			_tp = null
			_selected_tp = null
			#_is_show_add_project = -1

			_render_tp_detail = (tp, param)-> #渲染任务/项目详情信息
				tp = if _.isArray(tp) then tp else []

				tp_detail_tmpl = Handlebars.compile $("#tmp_#{type}_detail").html()
				is_related_tp = $("#is_related_#{type}").val()
				content = tp_detail_tmpl {
					is_related_tp: if tp then is_related_tp else null
					tp: tp
				}
				tp = _.chain(tp).map (x)->
					return if x then x._id else null
				.compact().value().join(',')
				$("#related_#{type}").val tp
				_selected_tp = tp
				$("##{type}_form_body").html(content)

				if param && param.view
					console.log('查看界面')
				else
					context[type + 'Util'].is_start_user (err, result)->
						if result
							$(".#{type}_select").parent().show()

							$(".#{type}_select").on('click', (event)->
							    context["#{type}Util"].selectTp()
							)
			return {
				tp: (_tps)->
					if _.isArray(_tps)
						_tp = _tps
					else
						return _tp
				getTp: (done)-> #获得任务/项目数据
			        _type = $('#is_related_' + type).val()
			        _value = $('#related_' + type).val()
			        if type == 'checkin'
			        	if typeof get_draw_item == 'function'
			        		items = get_draw_item()
			        		_value = if _value then _value.split(',') else []
			        		if _checkin_date
			        			if typeof done == 'function'
			        				done null, _tp
			        		else if _value.length > 0
			        			_default_date = moment()
			        			$.get("/wxapp/007/checkin/detail_do/#{_value[0]}").done (data)->
			        				if data && data.checkin_date && moment(data.checkin_date).isValid()
			        					_default_date = moment(data.checkin_date)
			        			.always ()->
			        				_checkin_date = _default_date.format 'YYYY-MM'
			        				$.post('/wxapp/007/checkin/list_do_new', {
			        					people_list: [$('#people_id').val()],
			        					start_date: _default_date.startOf('month').toDate().getTime(),
			        					end_date: _default_date.endOf('month').toDate().getTime(),
			        				}).done((data)-> #获取外勤签到信息
			        					_tp = data
			        					if typeof done == 'function'
			        						done(null, _tp)
			        				).fail((err)->
			        					if typeof done == 'function'
			        						done(err, _tp)
			        				)
			        		else if _.isArray(items) && items.length > 0 && moment(items[0].start_date).isValid() && moment(items[items.length - 1].end_date).isValid()
			        			if items[0].is_full_day
			        				start = moment(items[0].start_date + ' 00:00', 'YYYY-MM-DD HH:mm');
			        			else
			        				start = moment(items[0].start_date + ' ' + (if items[0].time_zone_s then items[0].time_zone_s else '00:00'), 'YYYY-MM-DD HH:mm');

			        			if items[items.length - 1].is_full_day
			        				end = moment(items[items.length - 1].end_date + ' 23:59', 'YYYY-MM-DD HH:mm');
			        			else
			        				end = moment(items[items.length - 1].end_date + ' ' + (if items[items.length - 1].time_zone_e then items[items.length - 1].time_zone_e else "23:59"), 'YYYY-MM-DD HH:mm');
			        			#start = moment(items[0].start_date + ' ' + items[0].time_zone_s, 'YYYY-MM-DD HH:mm');
			        			#end = moment(items[items.length - 1].end_date + ' ' + items[items.length - 1].time_zone_e, 'YYYY-MM-DD HH:mm');
			        			_checkin_date = moment(items[0].start_date, 'YYYY-MM-DD').format 'YYYY-MM'
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
			        else
			        	console.log('其他')
				selectTp: ()-> #选择项目
					self = this
					self.getTp((err, datas)->
						if err
							myApp.alert(err)
							return
						window[type + 'View'].render({
							datas: datas,
						})
						layer.open({ #弹层显示
							type: 1,
							title: false,
							closeBtn: 0,
							shadeClose: true,
							shade: 0.8,
							area: ['100%', '80%'],
							content: $('.' + type + '_container'),
							btn: ['确定', '取消'],
							btnAlign: 'c',
							zIndex: 1, #兼容mobiscroll的时间控件(z-index=2)
							yes: (index, layero)-> #确定的回调
								window[type + 'View'].selectedTp()
							no: (index)-> #取消的回调
								console.log '123'
							success: (layero, index)->
								$('.layui-layer-btn a').css({
									width: '45%'
								})
								if type == 'checkin'
									$checkin_date = $('.' + type + '_date')
									#$checkin_date.val _checkin_date || moment().format 'YYYY-MM'
									if !$checkin_date.val()
										mom = moment moment().format 'YYYY-MM'
										$.post('/wxapp/007/checkin/list_do_new', {
											people_list: [$('#people_id').val()],
											start_date: mom.startOf('month').toDate().getTime(),
											end_date: mom.endOf('month').toDate().getTime(),
										}).done((datas)-> #获取外勤签到信息
											_tp = datas
											self = window[type + 'View']

											self.$el.find('.checkin_list').remove()
											$(self.tmp_tp({datas:datas})).find('.checkin_list').each(()->
											    self.$el.append($(this))
											)
											$checkin_date = $('.' + type + '_date')
											$checkin_date.val(mom.format('YYYY-MM'));
											$checkin_date.mobiscroll('setValue', [mom.get('year'), mom.get('month')]);
										)
									$checkin_date.mobiscroll().date({
										theme: 'mobiscroll',
										lang: 'zh',
										display: 'bubble',
										swipeDirection: 'vertical',
										dateOrder: 'yymm',
										startYear: 2014,
										endYear: 2099,
										mode: 'mixed',
										dateFormat: 'yy-mm',
										#defaultValue: _checkin_date.toDate(),
										onSelect: (valueText, inst)->
											val = $checkin_date.val()
											mom = moment valueText, 'YYYY-MM'
											$.post('/wxapp/007/checkin/list_do_new', {
												people_list: [$('#people_id').val()],
												start_date: mom.startOf('month').toDate().getTime(),
												end_date: mom.endOf('month').toDate().getTime(),
											}).done((datas)-> #获取外勤签到信息
												_tp = datas
												self = window[type + 'View']

												self.$el.find('.checkin_list').remove()
												$(self.tmp_tp({datas:datas})).find('.checkin_list').each(()->
												    self.$el.append($(this))
												)
												$checkin_date = $('.' + type + '_date')
												$checkin_date.val(mom.format('YYYY-MM'));
												$checkin_date.mobiscroll('setValue', [mom.get('year'), mom.get('month')]);
											)
									})
						})
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
					tp_id = $('#related_' + type).val()
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
					is_related_tp = $("#is_related_#{type}").val()
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
