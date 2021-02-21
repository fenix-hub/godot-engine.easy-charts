tool
extends Spatial
class_name ScatterChart3D

"""
[ScatterChart] - General purpose node for Scatter Charts

A scatter plot (also called a scatterplot, scatter graph, scatter chart, scattergram, or scatter diagram)
 is a type of plot or mathematical diagram using Cartesian coordinates to display values for typically two variables 
for a set of data. If the points are coded (color/shape/size), one additional variable can be displayed. 
The data are displayed as a collection of points, each having the value of one variable determining the position on 
the horizontal axis and the value of the other variable determining the position on the vertical axis.

/ source : Wikipedia /
"""

onready var PlaceholderPoint = $Chart/Point
onready var Space = $ImmediateGeometry
onready var PointData = $PointData/PointData

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

var x_label : String
var z_label : String

# database values
var x_datas : Array
var z_datas : Array
var y_datas : Array

# labels displayed on chart
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
export (Vector2) var SIZE : Vector2 = Vector2() setget _set_size
export (String, FILE, "*.txt, *.csv") var source : String = ""
export (String) var delimiter : String = ";"
export (bool) var origin_at_zero : bool = true

export (bool) var are_values_columns : bool = false
export (int,0,100) var x_values_index : int = 0
export (int,0,100) var z_values_index : int = 0
export(bool) var show_x_values_as_labels : bool = true

#export (float,1,20,0.5) var column_width : float = 10
#export (float,0,10,0.5) var column_gap : float = 2

export (float,0.1,10.0) var x_decim : float = 5.0
export (float,0.1,10.0) var y_decim : float = 5.0
export (int,"Dot,Triangle,Square") var point_shape : int = 0
export (PoolColorArray) var function_colors = [Color("#1e1e1e")]
export (Color) var v_lines_color : Color = Color("#cacaca")
export (Color) var h_lines_color : Color = Color("#cacaca")

export (bool) var boxed : bool = true
export (Color) var box_color : Color = Color("#1e1e1e")
export (Font) var font : Font
export (Font) var bold_font : Font
export (Color) var font_color : Color = Color("#1e1e1e")
export (String,"Default","Clean","Gradient","Minimal","Invert") var template : String = "Default" setget apply_template
export (float,0.1,1) var drawing_duration : float = 0.5
export (bool) var invert_chart : bool = false

var templates : Dictionary = {}

signal chart_plotted(chart)
signal point_pressed(point)

func _point_plotted():
	pass

func _ready():
	pass

func _set_size(size : Vector2):
	SIZE = size
#	build_chart()

func clear():
	pass

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
#	count_functions()
	structure_datas(datas,are_values_columns_,x_values_index_)
#	build_chart()
#	calculate_pass()
#	calculate_coordinates()
#	calculate_colors()
#	draw_chart()
#
#	create_legend()
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
#	count_functions()
	structure_datas(datas,are_values_columns,x_values_index)
#	build_chart()
#	calculate_pass()
#	calculate_coordinates()
#	calculate_colors()
#	draw_chart()
	
#	create_legend()
	emit_signal("chart_plotted", self)


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
					elif column == z_values_index:
						var z_data = database[row][column]
						if z_data.is_valid_float() or z_data.is_valid_integer():
							z_datas.append(z_data as float)
						else:
							z_datas.append(z_data.replace(",",".") as float)
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
			z_label = str(z_datas.pop_front())
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

func set_legend(l : Array):
	legend = l

func get_legend():
	return legend

func apply_template(template_name : String):
	template = template_name
	templates = Utilities._load_templates()
	if template_name!=null and template_name!="":
		var custom_template = templates[template.to_lower()]
		function_colors = custom_template.function_colors
		v_lines_color = Color(custom_template.v_lines_color)
		h_lines_color = Color(custom_template.h_lines_color)
		box_color = Color(custom_template.outline_color)
		font_color = Color(custom_template.font_color)
	property_list_changed_notify()

func _enter_tree():
	_ready()
