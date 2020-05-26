tool
extends Chart

"""
[RadarChart] - General purpose node for Radar Charts
A radar chart is a graphical method of displaying multivariate data in the form 
of a two-dimensional chart of three or more quantitative variables represented on axes 
starting from the same point. The relative position and angle of the axes is typically 
uninformative, but various heuristics, such as algorithms that plot data as the maximal 
total area, can be applied to sort the variables (axes) into relative positions that reveal 
distinct correlations, trade-offs, and a multitude of other comparative measures.

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
export (String, FILE, "*.txt, *.csv") var source : String = "" setget set_source
export (String) var delimiter : String = ";"
#export (bool) var origin_at_zero : bool = true

export (bool) var are_values_columns : bool = false
export (int,-1,100) var labels_index : int = 0
export (int,-1,100) var function_names_index : int = 0
#export(bool) var show_x_values_as_labels : bool = true

#export (float,1,20,0.5) var column_width : float = 10
#export (float,0,10,0.5) var column_gap : float = 2
export (bool) var use_height_as_radius : bool = false
export (float) var radius : float = 150.0

#export (float,0.1,10.0) var x_decim : float = 5.0
#export (float,0.1,10.0) var y_decim : float = 5.0
export (float,0.1,100) var full_scale : float = 1.0

export (point_shapes) var point_shape : int = 0
export (PoolColorArray) var function_colors = [Color("#1e1e1e")]
export (Color) var outline_color : Color = Color("#1e1e1e")
export (Color) var grid_color : Color = Color("#1e1e1e")
export (Font) var font : Font
export (Font) var bold_font : Font
export (Color) var font_color : Color = Color("#1e1e1e")

export (templates_names) var template : int = Chart.templates_names.Default setget apply_template
#export (bool) var invert_chart : bool = false
export (float,0,360) var rotation : float = 0

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
	structure_datas(datas,are_values_columns_,x_values_index_)
	build_chart()
	count_functions()
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
	structure_datas(datas,are_values_columns,labels_index)
	build_chart()
	count_functions()
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
		if data.size() < 2 or data.empty():
			content.erase(data)
	return content

func structure_datas(database : Array, are_values_columns : bool, labels_index : int):
	# @x_values_index can be either a column or a row relative to x values
	# @y_values can be either a column or a row relative to y values
	self.labels_index = labels_index
	self.are_values_columns = are_values_columns
	match are_values_columns:
		true:
			for row in database.size():
				if row == labels_index:
					x_labels = database[row] as PoolStringArray
				else:
					if database[row].empty() or database[row].size() < 2:
						continue
					x_datas.append(PoolRealArray(database[row] as Array))
				
				for column in database[row].size():
					if column == function_names_index:
						y_labels.append(database[row][column])
		false:
			for row in database.size():
				if row == function_names_index:
					y_labels = database[row] as PoolStringArray
				
				var x_temp_datas : PoolRealArray = []
				for column in database[row].size():
					if column == labels_index:
						x_labels.append(database[row][column] as String)
					else:
						x_temp_datas.append(database[row][column] as float)
					x_datas.append(x_temp_datas)
	
	if labels_index == -1 :
		for data in x_datas[0].size():
			x_labels.append("Element %s" % data)
	
	if function_names_index == -1 :
		for data in x_datas.size():
			y_labels.append("Function %s" % data)

func build_chart():
	SIZE = get_size()
	origin = OFFSET + SIZE/2

var radar_polygon : Array

func calculate_pass() : 
	var ordered_max : Array
	for data in x_datas :
		var ordered_data : Array = (data as Array)
		ordered_data.sort()
		ordered_max.append(ordered_data.pop_back())
	ordered_max.sort()
	var max_value : float = ordered_max.pop_back()
	var dist = full_scale * pow(10.0,str(max_value).length()-2)
	var multi = 0
	var value = dist * multi
	x_chors.append(value as String)
	while value < max_value:
		multi+=1
		value = dist * multi
		x_chors.append(value as String)

func calculate_coordinates():
	for chor in x_chors.size():
		var inner_polyline : PoolVector2Array
		var scalar_factor : float = (x_chors[chor] as float/x_chors.back() as float)
		for function in functions:
			var angle : float =  ((2 * PI * function) / functions) - PI /2 + deg2rad(rotation)
			var x_coordinate : float = (radius if not use_height_as_radius else SIZE.y/2) * scalar_factor * cos(angle) + origin.x
			var y_coordinate : float = (radius if not use_height_as_radius else SIZE.y/2) * scalar_factor * sin(angle) + origin.y
			inner_polyline.append(Vector2(x_coordinate, y_coordinate))
		inner_polyline.append(inner_polyline[0])
		radar_polygon.append(inner_polyline)
	
	for datas in x_datas:
		var function_positions : PoolVector2Array
		var function_values : Array
		for data in datas.size():
			var scalar_factor : float = datas[data] /( x_chors.back() as float)
			var angle : float =  ((2 * PI * data) / datas.size()) - PI/2 + deg2rad(rotation)
			var x_coordinate : float = (radius if not use_height_as_radius else SIZE.y/2) * scalar_factor * cos(angle) + origin.x
			var y_coordinate : float = (radius if not use_height_as_radius else SIZE.y/2) * scalar_factor * sin(angle) + origin.y
			function_positions.append(Vector2(x_coordinate,y_coordinate))
			function_values.append([x_labels[data], datas[data]])
		function_positions.append(function_positions[0])
		point_positions.append(function_positions)
		point_values.append(function_values)

func redraw():
	build_chart()
	calculate_pass()
	calculate_coordinates()
	update()

func _draw():
	if Engine.editor_hint:
		return
	
	clear_points()
	draw_grid()
	
	for function in point_positions.size():
		var function_color : Color = function_colors[function]
		draw_polygon(point_positions[function], [Color(function_color.r, function_color.g, function_color.b, 0.2)],[],null,null,true)
		draw_polyline(point_positions[function], function_color, 2,true)
	
	for _function in point_values.size():
		var PointContainer : Control = Control.new()
		Points.add_child(PointContainer)
		
		for function_point in point_values[_function].size():
			var point : Point = point_node.instance()
			point.connect("_point_pressed",self,"point_pressed")
			point.connect("_mouse_entered",self,"show_data")
			point.connect("_mouse_exited",self,"hide_data")
			
			point.create_point(point_shape, function_colors[_function], 
			Color.white, point_positions[_function][function_point], 
			point.format_value(point_values[_function][function_point], false, false),
			y_labels[_function])
#			str("Function %s"%_function))
			
			PointContainer.add_child(point)

func draw_grid():
	for polyline in radar_polygon:
		draw_polyline(polyline, grid_color, 1, true)
		var text : String = x_chors[radar_polygon.find(polyline)] as String
		draw_string(font, polyline[0] - Vector2(font.get_string_size(text).x/2,-5), text, font_color)
	
	if not radar_polygon.empty():
		draw_polyline(radar_polygon[radar_polygon.size()-1], outline_color, 1, true)
	
	for label in x_labels.size():
		var point_array : PoolVector2Array = radar_polygon[radar_polygon.size()-1]
		draw_line(origin, point_array[label], grid_color, 1, true)
		draw_string(font, point_array[label] - (Vector2(font.get_string_size(x_labels[label]).x/2,0) if point_array[label].x < origin.x else - Vector2(5,0)), x_labels[label], font_color)



func create_legend():
	legend.clear()
	for function in functions:
		var function_legend = FunctionLegend.instance()
		var f_name : String = x_labels[function]
		var legend_font : Font
		if font != null:
			legend_font = font
		if bold_font != null:
			legend_font = bold_font
		function_legend.create_legend(f_name,function_colors[function],bold_font,font_color)
		legend.append(function_legend)

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

func count_functions():
	self.functions = x_labels.size()

func apply_template(template_name : int):
	template = template_name
	templates = Utilities._load_templates()
	if template_name!=null:
		var custom_template = templates.get(templates.keys()[template_name])
		function_colors = custom_template.function_colors as PoolColorArray
		outline_color = Color(custom_template.outline_color)
		grid_color = Color(custom_template.v_lines_color)
		font_color = Color(custom_template.font_color)
	property_list_changed_notify()

func _enter_tree():
	_ready()

func set_source(source_file : String):
	source = source_file
