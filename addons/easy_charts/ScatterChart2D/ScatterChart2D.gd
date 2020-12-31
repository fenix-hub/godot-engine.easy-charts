tool
extends Chart2D
class_name ScatterChart2D

"""
[ScatterChart2D] - General purpose node for Scatter Charts

A scatter plot (also called a scatterplot, scatter graph, scatter chart, scattergram, or scatter diagram)
 is a type of plot or mathematical diagram using Cartesian coordinates to display values for typically two variables 
for a set of data. If the points are coded (color/shape/size), one additional variable can be displayed. 
The data are displayed as a collection of points, each having the value of one variable determining the position on 
the horizontal axis and the value of the other variable determining the position on the vertical axis.

/ source : Wikipedia /
"""

func _point_plotted():
		pass

func _ready():
		_get_children()

func _get_children():
		OutlinesTween = $OutlinesTween
		PointTween = $PointTween
		Functions = $Functions
		GridTween = $GridTween
		PointData = $PointData/PointData
		Outlines = $Outlines
		Grid = $Grid

func _set_size(size : Vector2):
		SIZE = size
		build_chart()
		if Engine.editor_hint:
				_get_children()
				Outlines.set_point_position(0,Vector2(origin.x,0))
				Outlines.set_point_position(1,Vector2(SIZE.x,0))
				Outlines.set_point_position(2,Vector2(SIZE.x,origin.y))
				Outlines.set_point_position(3,origin)
				Outlines.set_point_position(4,Vector2(origin.x,0))
				
				Grid.get_node("VLine").set_point_position(0,Vector2((OFFSET.x+SIZE.x)/2,0))
				Grid.get_node("VLine").set_point_position(1,Vector2((OFFSET.x+SIZE.x)/2,origin.y))
				Grid.get_node("HLine").set_point_position(0,Vector2(origin.x,origin.y/2))
				Grid.get_node("HLine").set_point_position(1,Vector2(SIZE.x,origin.y/2))

func clear():
		Outlines.points = []
		Grid.get_node("HLine").queue_free()
		Grid.get_node("VLine").queue_free()

func load_font():
		if font != null:
				font_size = font.get_height()
				var theme : Theme = Theme.new()
				theme.set_default_font(font)
				PointData.set_theme(theme)
		else:
				var lbl = Label.new()
				font = lbl.get_font("")
				lbl.free()
		if bold_font != null:
				PointData.Data.set("custom_fonts/font",bold_font)

func _plot(source_ : String, delimiter_ : String, are_values_columns_ : bool, x_values_index_ : int):
		randomize()
		
		clear()
		
		load_font()
		PointData.hide()
		
		datas = read_datas(source_,delimiter_)
		count_functions()
		structure_datas(datas,are_values_columns_,x_values_index_)
		build_chart()
		calculate_pass()
		calculate_coordinates()
		calculate_colors()
		draw_chart()
		
		create_legend()
		emit_signal("chart_plotted", self)

func plot():
		randomize()
		
		clear()
		
		load_font()
		PointData.hide()
		
		if source == "" or source == null:
				Utilities._print_message("Can't plot a chart without a Source file. Please, choose it in editor, or use the custom function _plot().",1)
				return
		datas = read_datas(source,delimiter)
		count_functions()
		structure_datas(datas,are_values_columns,x_values_index)
		build_chart()
		calculate_pass()
		calculate_coordinates()
		calculate_colors()
		draw_chart()
		
		create_legend()
		emit_signal("chart_plotted", self)

func calculate_colors():
		if function_colors.empty() or function_colors.size() < functions:
				for function in functions:
						function_colors.append(Color("#1e1e1e") as Color)

func draw_chart():
		draw_outlines()
		draw_v_grid()
		draw_h_grid()
		draw_functions()

func draw_outlines():
		if boxed:
				Outlines.set_default_color(box_color)
				OutlinesTween.interpolate_method(Outlines,"add_point",
				Vector2(origin.x,0),Vector2(SIZE.x,0),drawing_duration*0.5,Tween.TRANS_QUINT,Tween.EASE_OUT)
				OutlinesTween.start()
				yield(OutlinesTween,"tween_all_completed")
				OutlinesTween.interpolate_method(Outlines,"add_point",
				Vector2(SIZE.x,0),Vector2(SIZE.x,origin.y),drawing_duration*0.5,Tween.TRANS_QUINT,Tween.EASE_OUT)
				OutlinesTween.start()
				yield(OutlinesTween,"tween_all_completed")
		OutlinesTween.interpolate_method(Outlines,"add_point",
		Vector2(SIZE.x,origin.y),origin,drawing_duration*0.5,Tween.TRANS_QUINT,Tween.EASE_OUT)
		OutlinesTween.start()
		yield(OutlinesTween,"tween_all_completed")
		OutlinesTween.interpolate_method(Outlines,"add_point",
		origin,Vector2(origin.x,0),drawing_duration*0.5,Tween.TRANS_QUINT,Tween.EASE_OUT)
		OutlinesTween.start()
		yield(OutlinesTween,"tween_all_completed")

func draw_v_grid():
		for p in x_chors.size():
				var point : Vector2 = origin+Vector2((p)*x_pass,0)
				var v_grid : Line2D = Line2D.new()
				Grid.add_child(v_grid)
				v_grid.set_width(1)
				v_grid.set_default_color(v_lines_color)
				add_label(point+Vector2(-const_width/2*x_chors[p].length(),font_size/2), x_chors[p])
				GridTween.interpolate_method(v_grid,"add_point",point,point-Vector2(0,SIZE.y-OFFSET.y),drawing_duration/(x_chors.size()),Tween.TRANS_EXPO,Tween.EASE_OUT)
				GridTween.start()
				yield(GridTween,"tween_all_completed")

func draw_h_grid():
		for p in y_chors.size():
				var point : Vector2 = origin-Vector2(0,(p)*y_pass)
				var h_grid : Line2D = Line2D.new()
				Grid.add_child(h_grid)
				h_grid.set_width(1)
				h_grid.set_default_color(h_lines_color)
				add_label(point-Vector2(y_chors[p].length()*const_width+font_size,font_size/2), y_chors[p])
				GridTween.interpolate_method(h_grid,"add_point",point,Vector2(SIZE.x,point.y),drawing_duration/(y_chors.size()),Tween.TRANS_EXPO,Tween.EASE_OUT)
				GridTween.start()
				yield(GridTween,"tween_all_completed")


func add_label(point : Vector2, text : String):
				var lbl : Label = Label.new()
				if font != null:
						lbl.set("custom_fonts/font",font)
				lbl.set("custom_colors/font_color",font_color)
				Grid.add_child(lbl)
				lbl.rect_position = point
				lbl.set_text(text)

func draw_functions():
		for function in point_positions.size():
				draw_function(function,point_positions[function])

func draw_function(f_index : int, function : Array):
		var pointv : Point 
		for point in function.size():
				pointv = point_node.instance()
				Functions.add_child(pointv)
				pointv.connect("_mouse_entered",self,"show_data")
				pointv.connect("_mouse_exited",self,"hide_data")
				pointv.connect("_point_pressed",self,"point_pressed")
				pointv.create_point(point_shape, function_colors[f_index], Color.white, function[point],
				pointv.format_value(point_values[f_index][point],false,false),
				y_labels[point if invert_chart else f_index] as String)
				yield(get_tree().create_timer(drawing_duration/function.size()), "timeout")


func read_datas(source : String, delimiter : String):
		var file : File = File.new()
		file.open(source,File.READ)
		var content : Array
		while not file.eof_reached():
				var line : PoolStringArray = file.get_csv_line(delimiter)
				content.append(line)
		file.close()
		for data in content:
				if data.size() < 2:
						content.erase(data)
		return content

func structure_datas(database : Array, are_values_columns : bool, x_values_index : int):
		# @x_values_index can be either a column or a row relative to x values
		# @y_values can be either a column or a row relative to y values
		self.are_values_columns = are_values_columns
		match are_values_columns:
				true:
						for row in database.size():
								var t_vals : Array
								for column in database[row].size():
										if column == x_values_index:
												var x_data = database[row][column]
												if x_data.is_valid_float() or x_data.is_valid_integer():
														x_datas.append(x_data as float)
												else:
														x_datas.append(x_data.replace(",",".") as float)
										else:
												if row != 0:
														var y_data = database[row][column]
														if y_data.is_valid_float() or y_data.is_valid_integer():
																t_vals.append(y_data as float)
														else:
																t_vals.append(y_data.replace(",",".") as float)
												else:
														y_labels.append(str(database[row][column]))
								if not t_vals.empty():
										y_datas.append(t_vals)
						x_label = str(x_datas.pop_front())
				false:
						for row in database.size():
								if row == x_values_index:
										x_datas = (database[row])
										x_label = x_datas.pop_front() as String
								else:
										var values = database[row] as Array
										y_labels.append(values.pop_front() as String)
										y_datas.append(values)
						for data in y_datas:
								for value in data.size():
										data[value] = data[value] as float
		
		# draw y labels
		var to_order : Array
		var to_order_min : Array
		for cluster in y_datas.size():
				# define x_chors and y_chors
				var ordered_cluster = y_datas[cluster] as Array
				ordered_cluster.sort()
				ordered_cluster = PoolIntArray(ordered_cluster)
				var margin_max = ordered_cluster[ordered_cluster.size()-1]
				var margin_min = ordered_cluster[0]
				to_order.append(margin_max)
				to_order_min.append(margin_min)
		
		to_order.sort()
		to_order_min.sort()
		var margin = to_order.pop_back()
		if not origin_at_zero:
				y_margin_min = to_order_min.pop_front()
		v_dist = y_decim * pow(10.0,str(margin).length()-2)
		var multi = 0
		var p = (v_dist*multi) + ((y_margin_min) if not origin_at_zero else 0)
		y_chors.append(p as String)
		while p < margin:
				multi+=1
				p = (v_dist*multi) + ((y_margin_min) if not origin_at_zero else 0)
				y_chors.append(p as String)
		
		# draw x_labels
		if not show_x_values_as_labels:
				to_order.clear()
				to_order = x_datas as PoolIntArray
				
				to_order.sort()
				margin = to_order.pop_back()
				if not origin_at_zero:
						x_margin_min = to_order.pop_front()
				h_dist = x_decim * pow(10.0,str(margin).length()-2)
				multi = 0
				p = (h_dist*multi) + ((x_margin_min) if not origin_at_zero else 0)
				x_labels.append(p as String)
				while p < margin:
						multi+=1
						p = (h_dist*multi) + ((x_margin_min) if not origin_at_zero else 0)
						x_labels.append(p as String)

func build_chart():
		origin = Vector2(OFFSET.x,SIZE.y-OFFSET.y)

func calculate_pass():
		if invert_chart:
				x_chors = y_labels as PoolStringArray
		else:
				if show_x_values_as_labels:
						x_chors = x_datas as PoolStringArray
				else:
						x_chors = x_labels
		
		# calculate distance in pixel between 2 consecutive values/datas
		x_pass = (SIZE.x - OFFSET.x) / (x_chors.size()-1)
		y_pass = origin.y / (y_chors.size()-1)

func calculate_coordinates():
		x_coordinates.clear()
		y_coordinates.clear()
		point_values.clear()
		point_positions.clear()
		
		if invert_chart:
				for column in y_datas[0].size():
						var single_coordinates : Array
						for row in y_datas:
								if origin_at_zero:
										single_coordinates.append((row[column]*y_pass)/v_dist)
								else:
										single_coordinates.append((row[column] - y_margin_min)*y_pass/v_dist)
						y_coordinates.append(single_coordinates)
		else:
				for cluster in y_datas:
						var single_coordinates : Array
						for value in cluster.size():
								if origin_at_zero:
										single_coordinates.append((cluster[value]*y_pass)/v_dist)
								else:
										single_coordinates.append((cluster[value] - y_margin_min)*y_pass/v_dist)
						y_coordinates.append(single_coordinates)
		
		if show_x_values_as_labels:
				for x in x_datas.size():
						x_coordinates.append(x_pass*x)
		else:
				for x in x_datas.size():
						if origin_at_zero:
								if invert_chart:
										x_coordinates.append(x_pass*x)
								else:
										x_coordinates.append(x_datas[x]*x_pass/h_dist)
						else:
								x_coordinates.append((x_datas[x] - x_margin_min)*x_pass/h_dist)
		
		for f in functions:
				point_values.append([])
				point_positions.append([])
		
		if invert_chart:
				for function in y_coordinates.size():
						for function_value in y_coordinates[function].size():
								if are_values_columns:
										point_positions[function_value].append(Vector2(x_coordinates[function]+origin.x, origin.y-y_coordinates[function][function_value]))
										point_values[function_value].append([x_datas[function_value],y_datas[function_value][function]])
								else:
										point_positions[function].append(Vector2(x_coordinates[function_value]+origin.x,origin.y-y_coordinates[function][function_value]))
										point_values[function].append([x_datas[function_value],y_datas[function_value][function]])
		else:
				for cluster in y_coordinates.size():
						for y in y_coordinates[cluster].size():
								if are_values_columns:
										point_values[y].append([x_datas[cluster],y_datas[cluster][y]])
										point_positions[y].append(Vector2(x_coordinates[cluster]+origin.x,origin.y-y_coordinates[cluster][y]))
								else:
										point_values[cluster].append([x_datas[y],y_datas[cluster][y]])
										point_positions[cluster].append(Vector2(x_coordinates[y]+origin.x,origin.y-y_coordinates[cluster][y]))

func redraw():
		build_chart()
		calculate_pass()
		calculate_coordinates()
		update()


func show_data(point):
		PointData.update_datas(point)
		PointData.show()

func hide_data():
		PointData.hide()

func clear_points():
		function_colors.clear()
		if Functions.get_children():
				for function in Functions.get_children():
						function.queue_free()

func set_legend(l : Array):
		legend = l

func get_legend():
		return legend

func invert_chart():
		invert_chart = !invert_chart
		count_functions()
		redraw()
		create_legend()

func count_functions():
		if are_values_columns:
				if not invert_chart:
						functions = datas[0].size()-1
				else:
						functions = datas.size()-1
		else:
				if invert_chart:
						functions = datas[0].size()-1
				else:
						functions = datas.size()-1

func create_legend():
		legend.clear()
		for function in functions:
				var function_legend = FunctionLegend.instance()
				var f_name : String
				if invert_chart:
						f_name = x_datas[function] as String
				else:
						f_name = y_labels[function]
				var legend_font : Font
				if font != null:
						legend_font = font
				if bold_font != null:
						legend_font = bold_font
				function_legend.create_legend(f_name,function_colors[function],bold_font,font_color)
				legend.append(function_legend)

func apply_template(template_name : int):
		template = template_name
		templates = Utilities._load_templates()
		if template_name!=null:
				var custom_template = templates.get(templates.keys()[template_name])
				function_colors = custom_template.function_colors as PoolColorArray
				v_lines_color = Color(custom_template.v_lines_color)
				h_lines_color = Color(custom_template.h_lines_color)
				box_color = Color(custom_template.outline_color)
				font_color = Color(custom_template.font_color)
		property_list_changed_notify()
		
		if Engine.editor_hint:
				_get_children()
				Outlines.set_default_color(box_color)
				Grid.get_node("VLine").set_default_color(v_lines_color)
				Grid.get_node("HLine").set_default_color(h_lines_color)


func _enter_tree():
		_ready()
