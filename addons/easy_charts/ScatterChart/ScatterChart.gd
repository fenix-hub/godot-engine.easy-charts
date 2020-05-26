tool
extends Chart

"""
[ScatterChart] - General purpose node for Scatter Charts

A scatter plot (also called a scatterplot, scatter graph, scatter chart, scattergram, or scatter diagram)
 is a type of plot or mathematical diagram using Cartesian coordinates to display values for typically two variables 
for a set of data. If the points are coded (color/shape/size), one additional variable can be displayed. 
The data are displayed as a collection of points, each having the value of one variable determining the position on 
the horizontal axis and the value of the other variable determining the position on the vertical axis.

/ source : Wikipedia /
"""

onready var PointData = $PointData/PointData
onready var Points = $Points
onready var Legend = $Legend

var point_node : PackedScene = preload("../Utilities/Point/Point.tscn")
var FunctionLegend : PackedScene = preload("../Utilities/Legend/FunctionLegend.tscn")

var font_size : float = 16
var const_height : float = font_size/2*font_size/20
var const_width : float = font_size/2

var OFFSET : Vector2 = Vector2(0,0)

#-------------------------------------------------------------------------#
var origin : Vector2

# actual distance between x and y values 
var x_pass : float
var y_pass : float

# vertical distance between y consecutive points used for intervals
var v_dist : float
var h_dist : float

# quantization, representing the interval in which values will be displayed


# define values on x an y axis
var x_chors : Array
var y_chors : Array

# actual coordinates of points (in pixel)
var x_coordinates : Array
var y_coordinates : Array

# datas contained in file
var datas : Array

# amount of functions to represent
var functions : int = 0


# database values
var x_datas : Array
var y_datas : Array

# labels displayed on chart
var x_label : String

var x_labels : Array
var y_labels : Array

var x_margin_min : int = 0
var y_margin_min : int = 0

# actual values of point, from the database
var point_values : Array

# actual position of points in pixel
var point_positions : Array

var legend : Array setget set_legend,get_legend

# ---------------------
var SIZE : Vector2 = Vector2()
export (String, FILE, "*.txt, *.csv") var source : String = ""
export (String) var delimiter : String = ";"
export (bool) var origin_at_zero : bool = true

export (bool) var are_values_columns : bool = false
export (int,0,100) var x_values_index : int = 0
export(bool) var show_x_values_as_labels : bool = true

#export (float,1,20,0.5) var column_width : float = 10
#export (float,0,10,0.5) var column_gap : float = 2

export (float,0.1,10.0) var x_decim : float = 5.0
export (float,0.1,10.0) var y_decim : float = 5.0
export (point_shapes) var point_shape : int = 0
export (PoolColorArray) var function_colors = [Color("#1e1e1e")]
export (Color) var v_lines_color : Color = Color("#cacaca")
export (Color) var h_lines_color : Color = Color("#cacaca")

export (bool) var boxed : bool = true
export (Color) var box_color : Color = Color("#1e1e1e")
export (Font) var font : Font
export (Font) var bold_font : Font
export (Color) var font_color : Color = Color("#1e1e1e")
export (templates_names) var template : int = templates_names.Default setget apply_template
export (bool) var invert_chart : bool = false


var templates : Dictionary = {}

signal chart_plotted(chart)
signal point_pressed(point)


func _ready():
	pass

func _plot(source_ : String, delimiter_ : String, are_values_columns_ : bool, x_values_index_ : int, invert_chart_ : bool = false):
	randomize()
	
	load_font()
	PointData.hide()
	
	datas = read_datas(source_,delimiter_)
	count_functions()
	structure_datas(datas,are_values_columns_,x_values_index_)
	build_chart()
	calculate_pass()
	calculate_coordinates()
	calculate_colors()
	create_legend()
	emit_signal("chart_plotted")

func plot():
	randomize()
	
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
	create_legend()
	emit_signal("chart_plotted")

func calculate_colors():
	if function_colors.empty() or function_colors.size() < functions:
		for function in functions:
			function_colors.append(Color("#1e1e1e"))

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
	SIZE = get_size()
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

func _draw():
	clear_points()
	
	draw_grid()
	draw_chart_outlines()
	
	var defined_colors : bool = false
	if function_colors.size():
		defined_colors = true
	
	for _function in point_values.size():
		var PointContainer : Control = Control.new()
		Points.add_child(PointContainer)
		
		for function_point in point_values[_function].size():
			var point : Point = point_node.instance()
			point.connect("_point_pressed",self,"point_pressed")
			point.connect("_mouse_entered",self,"show_data")
			point.connect("_mouse_exited",self,"hide_data")
			
			point.create_point(point_shape, function_colors[function_point if invert_chart else _function], 
			Color.white, point_positions[_function][function_point], 
			point.format_value(point_values[_function][function_point], false, false), 
			y_labels[function_point if invert_chart else _function] as String)
			
			PointContainer.add_child(point)

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

func draw_grid():
	# ascisse
	for p in x_chors.size():
		var point : Vector2 = origin+Vector2((p)*x_pass,0)
		# v grid
		draw_line(point,point-Vector2(0,SIZE.y-OFFSET.y),v_lines_color,0.2,true)
		# ascisse
		draw_line(point-Vector2(0,5),point,v_lines_color,1,true)
		draw_string(font,point+Vector2(-const_width/2*x_chors[p].length(),font_size+const_height),x_chors[p],font_color)
	
	# ordinate
	for p in y_chors.size():
		var point : Vector2 = origin-Vector2(0,(p)*y_pass)
		# h grid
		draw_line(point,point+Vector2(SIZE.x-OFFSET.x,0),h_lines_color,0.2,true)
		# ordinate
		draw_line(point,point+Vector2(5,0),h_lines_color,1,true)
		draw_string(font,point-Vector2(y_chors[p].length()*const_width+font_size,-const_height),y_chors[p],font_color)

func draw_chart_outlines():
	draw_line(origin,SIZE-Vector2(0,OFFSET.y),box_color,1,true)
	draw_line(origin,Vector2(OFFSET.x,0),box_color,1,true)
	draw_line(Vector2(OFFSET.x,0),Vector2(SIZE.x,0),box_color,1,true)
	draw_line(Vector2(SIZE.x,0),SIZE-Vector2(0,OFFSET.y),box_color,1,true)

var can_grab_x : bool = false
var can_grab_y : bool = false
var can_move : bool = false
var range_mouse : float = 7

#func _input(event):
#	if not can_grab_x and (event.position.x > (SIZE.x-range_mouse + rect_position.x) and event.position.x < (SIZE.x+range_mouse + rect_position.x)) :
#		set_default_cursor_shape(Control.CURSOR_HSIZE)
#		if Input.is_action_pressed("mouse_left"):
#				can_grab_x = true
#
#	if Input.is_action_just_released("mouse_left") and can_grab_x:
#		can_grab_x = false
#
#	if not can_grab_y and (event.position.y > ( rect_position.y + origin.y-range_mouse) and event.position.y < (rect_position.y+ origin.y+range_mouse)) :
#		set_default_cursor_shape(Control.CURSOR_VSIZE)
#		if Input.is_action_pressed("mouse_left"):
#				can_grab_y = true
#
#	if Input.is_action_just_released("mouse_left") and can_grab_y:
#		can_grab_y = false
#
#	if (event.position.x > SIZE.x-range_mouse+rect_position.x and event.position.x < SIZE.x+range_mouse + rect_position.x) and (event.position.y > rect_position.y+origin.y-range_mouse and event.position.y < rect_position.y+origin.y+range_mouse):
#		set_default_cursor_shape(Control.CURSOR_FDIAGSIZE)
#	if not (event.position.x > SIZE.x-range_mouse+rect_position.x and event.position.x < SIZE.x+range_mouse + rect_position.x) and not (event.position.y > rect_position.y+ origin.y-range_mouse and event.position.y < rect_position.y+origin.y+range_mouse ):
#		set_default_cursor_shape(Control.CURSOR_ARROW)

#
#func _process(delta):
#	if can_grab_x:
#		PointData.hide()
#		get_parent().rect_size.x = get_global_mouse_position().x - rect_position.x
#		redraw()
#
#	if can_grab_y:
#		PointData.hide()
#		get_parent().rect_size.y = get_global_mouse_position().y - rect_position.y + OFFSET.y
#		redraw()

func show_data(point):
	PointData.update_datas(point)
	PointData.show()

func hide_data():
	PointData.hide()

func clear_points():
	if Points.get_children():
		for function in Points.get_children():
			function.queue_free()
	for legend in Legend.get_children():
		legend.queue_free()

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

func _enter_tree():
	templates = Utilities._load_templates()
	_ready()
