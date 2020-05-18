tool
extends Control

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

# quantization, representing the interval in which values will be displayed
var x_decim : float = 1.0

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
var y_labels : Array

# actual values of point, from the database
var point_values : Array

# actual position of points in pixel
var point_positions : Array

var legend : Array setget set_legend,get_legend

# ---------------------
var SIZE : Vector2 = Vector2()
export (String, FILE) var source : String = ""
export (String) var delimiter : String = ";"

export (bool) var are_values_columns : bool = false
export (bool) var invert_xy : bool = false

export (int,0,100) var x_values : int = 0

export (float,1,20,0.5) var column_width : float = 10
export (float,0,10,0.5) var column_gap : float = 2

export (float,0,10) var y_decim : float = 5.0
export (PoolColorArray) var function_colors = [Color("#1e1e1e")]

export (bool) var boxed : bool = true
export (Color) var v_lines_color : Color = Color("#cacaca")
export (Color) var h_lines_color : Color = Color("#cacaca")
export (Color) var outline_color : Color = Color("#1e1e1e")
export (Font) var font : Font
export (Font) var bold_font : Font
export (Color) var font_color : Color = Color("#1e1e1e")
export (String,"Default","Clean","Gradient","Minimal","Invert") var template : String = "Default" setget apply_template

var templates : Dictionary = {}

signal chart_plotted(chart)
signal point_pressed(point)


func _ready():
	pass

func _plot(source_ : String, delimiter_ : String, are_values_columns_ : bool, x_values_ : int, invert_xy_ : bool = false):
	randomize()
	
	load_font()
	PointData.hide()
	
	datas = read_datas(source_,delimiter_)
	count_functions()
	structure_datas(datas,are_values_columns_,x_values_)
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
	structure_datas(datas,are_values_columns,x_values)
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

func structure_datas(database : Array, are_values_columns : bool, x_values : int):
	# @x_values can be either a column or a row relative to x values
	# @y_values can be either a column or a row relative to y values
	self.are_values_columns = are_values_columns
	match are_values_columns:
		true:
			for row in database.size():
				var t_vals : Array
				for column in database[row].size():
					if column == x_values:
						x_datas.append(database[row][column])
					else:
						if row != 0:
							t_vals.append(float(database[row][column]))
						else:
							y_labels.append(str(database[row][column]))
				if not t_vals.empty():
					y_datas.append(t_vals)
			x_label = str(x_datas.pop_front())
		false:
			for row in database.size():
				if row == x_values:
					x_datas = (database[row])
					x_label = x_datas.pop_front() as String
				else:
					var values = database[row] as Array
					y_labels.append(values.pop_front() as String)
					y_datas.append(values)
			for data in y_datas:
				for value in data.size():
					data[value] = data[value] as float
	
	var to_order : Array
	for cluster in y_datas.size():
		# define x_chors and y_chors
		var margin = y_datas[cluster][y_datas[cluster].size()-1]
		to_order.append(margin)
	
	to_order.sort()
	var margin = to_order.pop_back()
	v_dist = y_decim * pow(10.0,str(margin).length()-2)
	var multi = 0
	var p = v_dist*multi
	y_chors.append(p as String)
	while p < margin:
		multi+=1
		p = v_dist*multi
		y_chors.append(p as String)

func build_chart():
	SIZE = get_size()
	origin = Vector2(OFFSET.x,SIZE.y-OFFSET.y)

func calculate_pass():
	if invert_xy:
		x_chors = y_labels as PoolStringArray
	else:
		x_chors = x_datas as PoolStringArray
	# calculate distance in pixel between 2 consecutive values/datas
	x_pass = (SIZE.x - OFFSET.x) / (x_chors.size()-1)
	y_pass = origin.y / (y_chors.size()-1)

func calculate_coordinates():
	x_coordinates.clear()
	y_coordinates.clear()
	point_values.clear()
	point_positions.clear()
	
	if invert_xy:
		for column in y_datas[0].size():
			var single_coordinates : Array
			for row in y_datas:
				single_coordinates.append((row[column]*y_pass)/v_dist)
			y_coordinates.append(single_coordinates)
	else:
		for cluster in y_datas:
			var single_coordinates : Array
			for value in cluster.size():
				single_coordinates.append((cluster[value]*y_pass)/v_dist)
			y_coordinates.append(single_coordinates)
	
	for x in x_chors.size():
		x_coordinates.append(x_pass*x)
	
	for f in functions:
		point_values.append([])
		point_positions.append([])
	
	if invert_xy:
		for function in y_coordinates.size()-1:
			for function_value in y_coordinates[function].size():
				point_positions[function].append(Vector2(x_coordinates[function_value]+origin.x,origin.y-y_coordinates[function][function_value]))
				point_values[function].append([x_chors[function_value],y_datas[function_value][function]])
	else:
		for cluster in y_coordinates.size():
			for y in y_coordinates[cluster].size():
				point_values[cluster].append([x_chors[y],y_datas[cluster][y]])
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
		
		if invert_xy:
			for function_point in point_values[_function].size():
				var point : Control = point_node.instance()
				point.connect("_mouse_entered",self,"show_data",[point])
				point.connect("_mouse_exited",self,"hide_data")
				point.create_point(function_colors[_function], Color.white, point_positions[_function][function_point],point.format_value(point_values[_function][function_point],false,true),x_datas[_function])
				PointContainer.add_child(point)
				if function_point > 0:
					draw_line(point_positions[_function][function_point-1],point_positions[_function][function_point],function_colors[_function],2,true)
		else:
			for function_point in point_values[_function].size():
				var point : Control = point_node.instance()
				point.connect("_mouse_entered",self,"show_data",[point])
				point.connect("_mouse_exited",self,"hide_data")
				point.create_point(function_colors[_function], Color.white, point_positions[_function][function_point],point.format_value(point_values[_function][function_point],false,true),y_labels[_function])
				PointContainer.add_child(point)
				if function_point > 0:
					draw_line(point_positions[_function][function_point-1],point_positions[_function][function_point],function_colors[_function],2,true)

func create_legend():
	legend.clear()
	for function in functions:
		var function_legend = FunctionLegend.instance()
		var f_name : String
		if invert_xy:
			f_name = x_datas[function]
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
	draw_line(origin,SIZE-Vector2(0,OFFSET.y),outline_color,1,true)
	draw_line(origin,Vector2(OFFSET.x,0),outline_color,1,true)
	draw_line(Vector2(OFFSET.x,0),Vector2(SIZE.x,0),outline_color,1,true)
	draw_line(Vector2(SIZE.x,0),SIZE-Vector2(0,OFFSET.y),outline_color,1,true)

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


func _process(delta):
	if can_grab_x:
		PointData.hide()
		get_parent().rect_size.x = get_global_mouse_position().x - rect_position.x
		redraw()
	
	if can_grab_y:
		PointData.hide()
		get_parent().rect_size.y = get_global_mouse_position().y - rect_position.y + OFFSET.y
		redraw()

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
	invert_xy = !invert_xy
	count_functions()
	redraw()
	create_legend()

func count_functions():
	if are_values_columns:
		if not invert_xy:
			functions = datas[0].size()-1
		else:
			functions = datas.size()-1
	else:
		if invert_xy:
			functions = datas[0].size()-1
		else:
			functions = datas.size()-1

func apply_template(template_name : String):
	if Engine.editor_hint:
		if template_name!=null and template_name!="":
			template = template_name
			var custom_template = templates[template_name.to_lower()]
			function_colors = custom_template.function_colors
			v_lines_color = Color(custom_template.v_lines_color)
			h_lines_color = Color(custom_template.h_lines_color)
			outline_color = Color(custom_template.outline_color)
			font_color = Color(custom_template.font_color)
			property_list_changed_notify()


func _script_changed():
	_ready()

func _enter_tree():
	templates = Utilities._load_templates()
