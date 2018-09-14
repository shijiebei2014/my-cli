types = ['checkin']
capitalize_first_letter = (string)-> #//首字母大写
	if string && string.length > 0
		return string[0].toUpperCase() + string.substring(1)
	return string

for type in types
	((type)->			
		window[type + 'Util'] = ((context)->
			_checkin_date = null
			_c_f_l = capitalize_first_letter(type)
			_tb = null
			_tp = null
			_is_show_add_project = -1
			tmpl = Handlebars.compile($('#tmp_' + type).html())
			tp_detail_tmpl = Handlebars.compile($('#tmp_' + type + '_detail').html())

			_render_tp_detail = (tp)-> #渲染任务/项目详情信息
				tp = if _.isArray(tp) then tp else []

				is_related_tp = $("#is_related_" + type).val()
				content = tp_detail_tmpl {
					is_related_tp: if tp then is_related_tp else null
					tp: tp
				}
				tp = _.chain(tp).map (x)-> 
					return if x then x._id else null
				.compact().value().join(',')
				$('#related_' + type).val tp
				$('#show_' + type + '_container').html(content)
			    
				context[type + 'Util'].is_start_user (err, result)->
					if result
						$('.' + type + '_select').show()
			return {
				tp: (_tps)->
					if _.isArray(_tps)
						_tp = _tps
					else 
						return _tp
				getTp: (done)-> #获得外勤签到数据
					_type = $('#is_related_' + type).val()
					_value = $('#related_' + type).val()
					if type == 'checkin'
						if typeof get_draw_item == 'function'
							items = get_draw_item()
							_value = if _value then _value.split(',') else []
							if _checkin_date
								if typeof done == 'function'
									done null, null
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
									start = moment(items[0].start_date + ' ' + (if items[0].time_zone_s then items[0].time_zone_s else "00:00"), 'YYYY-MM-DD HH:mm');

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
							show_notify_msg(err, 'ERR')
							return
						if !$.fn.DataTable.fnIsDataTable($('#tbl' + _c_f_l)[0])
							if type == 'checkin'
								content = tmpl({datas: datas})
								$('#tbl' + _c_f_l).html content
								
								$('.all_' + type)
									.on 'change', (event)->
										event.preventDefault()
										is_all = $(this).attr('checked')
										_checkboxs = $("#tbl" + _c_f_l + " :checkbox")
										_checkboxs.each ()->
											_checked = $(this)
											if is_all
												if !_checked.attr("checked")
											    	_checked.attr("checked", true)
											else 
												if _checked.attr("checked")
											    	_checked.attr("checked", false)
								$checkin_date = $('.' + type + '_date')
								
								$checkin_date.val _checkin_date || moment().format 'YYYY-MM'
								$checkin_date.mobiscroll().date {
						            theme: 'mobiscroll',
						            lang: 'zh',
						            display: 'bubble',
						            swipeDirection: 'vertical',
								    dateOrder: 'yymm',
									startYear: 2014,
									endYear: 2030,
									mode: 'mixed',
									dateFormat: 'yy-mm',
									onSelect: (valueText, inst)->
										val = $checkin_date.val()
										mom = moment(valueText, 'YYYY-MM')

										$.post('/wxapp/007/checkin/list_do_new', {
										    people_list: [$('#people_id').val()],
										    start_date: mom.startOf('month').toDate().getTime(),
										    end_date: mom.endOf('month').toDate().getTime(),
										}).done((datas)-> #获取外勤签到信息
											_tp = datas
											if $.fn.DataTable.fnIsDataTable($('#tbl' + _c_f_l)[0])
												content = tmpl({datas: datas})
												_tb.fnClearTable()
												$("#tbl#{{_c_f_l}} tbody").empty()
												$($(content)[1]).find('tr').each ()->
													rows = []
													$(this).find('td').each ()->
														rows.push $(this).html()
													_tb.fnAddData rows
										)
								}
								$('.' + type + '_pre_month,.' + type + '_next_month')
									.on 'click', (e)->
										e.preventDefault()
										$this = $(this)
										dx = Number $this.data 'dx'
										if dx
											val = $checkin_date.val()
											mom = moment(val, 'YYYY-MM').add(dx, 'month')
											$checkin_date.val mom.format('YYYY-MM')
											$checkin_date.mobiscroll('setValue', [mom.get('year'), mom.get('month')])
											$checkin_date.mobiscroll('select')

											$.post('/wxapp/007/checkin/list_do_new', {
											    people_list: [$('#people_id').val()],
											    start_date: mom.startOf('month').toDate().getTime(),
											    end_date: mom.endOf('month').toDate().getTime(),
											}).done((datas)-> #获取外勤签到信息
												_tp = datas
												if $.fn.DataTable.fnIsDataTable($('#tbl' + _c_f_l)[0])
													content = tmpl({datas: datas})
													_tb.fnClearTable()
													$("#tbl#{{_c_f_l}} tbody").empty()
													$($(content)[1]).find('tr').each ()->
														rows = []
														$(this).find('td').each ()->
															rows.push $(this).html()
														_tb.fnAddData rows
											)
							_tb = $("#tbl#{_c_f_l}").dataTable({
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
						else
							if $.fn.DataTable.fnIsDataTable($('#tbl' + _c_f_l)[0])
								content = tmpl({datas: datas})
								_tb.fnClearTable()
								$("#tbl#{{_c_f_l}} tbody").empty()
								$($(content)[1]).find('tr').each ()->
									rows = []
									$(this).find('td').each ()->
										rows.push $(this).html()
									_tb.fnAddData rows
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
				firstRender: ()->
					self = this
					is_related_tp = $('#is_related_' + type).val()
					tp_id = null
					tp = $('#related_' + is_related_tp).val()
					tp = if tp then tp.split(',') else []
					if tp.length > 0
						self.is_start_user (err, result)->
							if type == 'checkin'
								$.post('/wxapp/007/checkin/details', {
									checkin_ids: tp
								}).done((data)->
									_tp = data
									_render_tp_detail(data || null)
								).fail((err)->
									_render_tp_detail(null)
								)
							else 
								console.log('其他')
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