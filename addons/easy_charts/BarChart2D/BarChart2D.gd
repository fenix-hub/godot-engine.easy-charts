tool
extends Node2D


"""
[BarChart2D] - General purpose node for Bar Charts

A bar chart or bar graph is a chart or graph that presents categorical data with 
rectangular bars with heights or lengths proportional to the values that they represent. 
The bars can be plotted vertically or horizontally. A vertical bar chart is sometimes 
called a column chart.
A bar graph shows comparisons among discrete categories. One axis of the chart shows 
the specific categories being compared, and the other axis represents a measured value. 
Some bar graphs present bars clustered in groups of more than one, showing the 
values of more than one measured variable.

/ source : Wikipedia /
"""

onready var FunctionsTween : Tween = $FunctionsTween
onready var OutlinesTween : Tween = $OutlinesTween
onready var GridTween : Tween = $GridTween
onready var Functions : Node2D = $Functions
onready var PointData = $PointData/PointData
onready var Outlines : Line2D = $Outlines
onready var Grid : Node2D = $Grid

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
#export (bool) 
export (Vector2) var SIZE : Vector2 = Vector2()
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
export (float,0.01,1) var drawing_duration : float = 0.3
export (Font) var font : Font
export (Font) var bold_font : Font
export (Color) var font_color : Color = Color("#1e1e1e")
export (String,"Default","Clean","Gradient","Minimal","Invert") var template : String = "Default" setget apply_template

var templates : Dictionary = {}

signal chart_plotted(chart)
signal point_pressed(point)

func _point_drawn():
	pass

func _ready():
	pass

func _script_changed():
	_ready()

func _process(delta):
	if Engine.editor_hint:
		Outlines.set_default_color(outline_color)
		Grid.get_node("VLine").set_default_color(v_lines_color)
		Grid.get_node("HLine").set_default_color(h_lines_color)
		if function_colors.size():
			Functions.get_node("Function").set_default_color(function_colors[0])
		else:
			Functions.get_node("Function").set_default_color(Color("#1e1e1e"))
		
		if SIZE!=Vector2():
			build_chart()
			Outlines.set_point_position(0,Vector2(origin.x,0))
			Outlines.set_point_position(1,Vector2(SIZE.x,0))
			Outlines.set_point_position(2,Vector2(SIZE.x,origin.y))
			Outlines.set_point_position(3,origin)
			Outlines.set_point_position(4,Vector2(origin.x,0))
			
			Grid.get_node("VLine").set_point_position(0,Vector2((OFFSET.x+SIZE.x)/2,0))
			Grid.get_node("VLine").set_point_position(1,Vector2((OFFSET.x+SIZE.x)/2,origin.y))
			Grid.get_node("HLine").set_point_position(0,Vector2(origin.x,origin.y/2))
			Grid.get_node("HLine").set_point_position(1,Vector2(SIZE.x,origin.y/2))
			
			if function_colors.size():
				Functions.get_node("Function").set_point_position(0,Vector2((OFFSET.x+SIZE.x)/2,origin.y))
				Functions.get_node("Function").set_point_position(1,Vector2((OFFSET.x+SIZE.x)/2,0))

#func _ready():
#	plot_line_chart("res://ChartNode/datas2.csv",";",false,0,invert_xy,function_colors,drawing_duration,SIZE)

func clear():
	Outlines.points = []
	Grid.get_node("HLine").queue_free()
	Grid.get_node("VLine").queue_free()
	Functions.get_node("Function").queue_free()

func load_font():
	if font != null:
		font_size = font.get_height()
		var theme : Theme = Theme.new()
		theme.set_default_font(font)
		PointData.set_theme(theme)
	if bold_font != null:
		PointData.Data.set("custom_fonts/font",bold_font)

func _plot(source_ : String, delimiter_ : String, are_values_columns_ : bool, x_values_ : int):
	randomize()
	
	clear()
	
	load_font()
	PointData.hide()
	
	datas = read_datas(source_,delimiter_)
	count_functions()
	structure_datas(datas,are_values_columns_,x_values_)
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
	structure_datas(datas,are_values_columns,x_values)
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
			function_colors.append(Color("#1e1e1e"))

func draw_chart():
	draw_outlines()
	draw_v_grid()
	draw_h_grid()
	draw_functions()

func draw_outlines():
	if boxed:
		Outlines.set_default_color(outline_color)
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
		var point : Vector2 = origin+Vector2((p)*x_pass + OFFSET.x/2,0)
		var v_grid : Line2D = Line2D.new()
		Grid.add_child(v_grid)
		v_grid.set_width(1)
		v_grid.set_default_color(v_lines_color)
		add_label(point+Vector2(-const_width/2*x_chors[p].length() + (column_width/2) * ( y_datas.size() if not invert_xy else y_datas[0].size()+1 ) + column_gap,font_size/2), x_chors[p])
		GridTween.interpolate_method(v_grid,"add_point",Vector2(point.x,origin.y),Vector2(point.x,origin.y-5),drawing_duration/(x_chors.size()),Tween.TRANS_EXPO,Tween.EASE_OUT)
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
	for point in function.size():
		var line : Line2D = Line2D.new()
		var pointv : Control 
		pointv = point_node.instance()
		line.add_child(pointv)
		pointv.connect("_mouse_entered",self,"show_data",[pointv])
		pointv.connect("_mouse_exited",self,"hide_data")
		pointv.connect("_point_pressed",self,"point_pressed")
		pointv.create_point(function_colors[f_index], Color.white, function[point]+Vector2(0,5), pointv.format_value(point_values[f_index][point],false,true),(x_datas[f_index] if invert_xy else y_labels[f_index]))
		pointv.rect_size.y =  origin.y - function[point].y
		construct_column(line,f_index,function)
		FunctionsTween.interpolate_method(line,"add_point",Vector2(function[point].x,origin.y),function[point],drawing_duration/function.size(),Tween.TRANS_QUINT,Tween.EASE_OUT)
		FunctionsTween.start()
		yield(FunctionsTween,"tween_all_completed")

func construct_column(line : Line2D, f_index : int, function : Array):
	line.set_width(column_width)
	line.set_default_color(function_colors[f_index])
	line.antialiased = true
	Functions.add_child(line)

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
	origin = Vector2(OFFSET.x,SIZE.y-OFFSET.y)

func calculate_pass():
	if invert_xy:
		x_chors = y_labels as PoolStringArray
	else:
		x_chors = x_datas as PoolStringArray
	# calculate distance in pixel between 2 consecutive values/datas
	x_pass = (SIZE.x - OFFSET.x*2 - (column_width) * ( y_datas.size() if not invert_xy else y_datas[0].size()+1 )  - column_gap - column_width/2) / (x_chors.size()-1)
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
		for function in y_coordinates.size():
			for function_value in y_coordinates[function].size():
				point_positions[function].append(Vector2(OFFSET.x/2 + column_width/2 + (column_width + column_gap)*function + x_coordinates[function_value]+origin.x, origin.y-y_coordinates[function][function_value]))
				point_values[function].append([x_chors[function_value],y_datas[function_value][function]])
	else:
		for cluster in y_coordinates.size():
			for y in y_coordinates[cluster].size():
				point_values[cluster].append([x_chors[y],y_datas[cluster][y]])
				point_positions[cluster].append(Vector2(OFFSET.x/2 + column_width/2 + (column_width + column_gap)*cluster + x_coordinates[y]+origin.x, origin.y-y_coordinates[cluster][y]))

func redraw():
	pass

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

func set_legend(l : Array):
	legend = l

func get_legend() -> Array:
	return legend

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

func point_pressed(point : Point):
	emit_signal("point_pressed",point)

func _enter_tree():
	templates = Utilities._load_templates()
