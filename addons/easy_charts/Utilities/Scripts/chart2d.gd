tool
extends Node2D
class_name Chart2D

enum PointShapes { Dot, Triangle, Square, Cross }
enum TemplatesNames { Default, Clean, Gradient, Minimal, Invert }


signal chart_plotted(chart)
signal point_pressed(point)


const OFFSET: Vector2 = Vector2(0,0)


export (Vector2) var SIZE: Vector2 = Vector2() setget _set_size
export (String, FILE, "*.txt, *.csv") var source: String = ""
export (String) var delimiter: String = ";"
export (bool) var origin_at_zero: bool = true

export (bool) var are_values_columns: bool = false
export (int, 0, 100) var x_values_index: int = 0
export(bool) var show_x_values_as_labels: bool = true

export (float,1,20,0.5) var column_width: float = 10
export (float,0,10,0.5) var column_gap: float = 2

export (float, 0.1, 10.0) var x_decim: float = 5.0
export (float, 0.1, 10.0) var y_decim: float = 5.0
export (PointShapes) var point_shape: int = 0
export (PoolColorArray) var function_colors = [Color("#1e1e1e")]
export (Color) var v_lines_color: Color = Color("#cacaca")
export (Color) var h_lines_color: Color = Color("#cacaca")

export (bool) var boxed: bool = true
export (Color) var box_color: Color = Color("#1e1e1e")
export (Font) var font: Font
export (Font) var bold_font: Font
export (Color) var font_color: Color = Color("#1e1e1e")
export var template : int = 0 setget apply_template
export (float, 0.1, 1) var drawing_duration: float = 0.5
export (bool) var invert_chart: bool = false


var OutlinesTween: Tween
var FunctionsTween: Tween
var PointTween : Tween
var Functions: Node2D
var GridTween: Tween
var PointData: PointData
var Outlines: Line2D
var Grid: Node2D

var point_node: PackedScene = preload("../Point/point.tscn")
var FunctionLegend: PackedScene = preload("../Legend/function_legend.tscn")

var font_size: float = 16
var const_height: float = font_size / 2 * font_size / 20
var const_width: float = font_size / 2

var origin: Vector2

# actual distance between x and y values
var x_pass: float
var y_pass: float

# vertical distance between y consecutive points used for intervals
var v_dist: float
var h_dist: float

# quantization, representing the interval in which values will be displayed

# define values on x an y axis
var x_chors: Array
var y_chors: Array

# actual coordinates of points (in pixel)
var x_coordinates: Array
var y_coordinates: Array

# datas contained in file
var datas: Array

# amount of functions to represent
var functions: int = 0

var x_label: String

# database values
var x_datas: Array
var y_datas: Array

# labels displayed on chart
var x_labels: Array
var y_labels: Array

var x_margin_min: int = 0
var y_margin_min: int = 0

# actual values of point, from the database
var point_values: Array

# actual position of points in pixel
var point_positions: Array

var legend: Array setget set_legend, get_legend

var templates: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
		pass # Replace with function body.

func build_chart():
	pass

func calculate_pass():
	pass

func calculate_coordinates():
	pass

func _set_size(v : Vector2):
	SIZE = v

func _get_children():
	OutlinesTween = $OutlinesTween
	FunctionsTween = $FunctionsTween
	Functions = $Functions
	GridTween = $GridTween
	PointData = $PointData/PointData
	Outlines = $Outlines
	Grid = $Grid

func apply_template(template_name: int):
	template = template_name
	templates = Utilities._load_templates()
	if template_name != null:
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

func count_functions():
	if are_values_columns:
		if not invert_chart:
			functions = datas[0].size() - 1
		else:
			functions = datas.size() - 1
	else:
		if invert_chart:
			functions = datas[0].size() - 1
		else:
			functions = datas.size() - 1

func set_legend(l: Array):
	legend = l


func get_legend():
	return legend


func create_legend():
	legend.clear()
	for function in functions:
		var function_legend = FunctionLegend.instance()
		var f_name: String
		if invert_chart:
			f_name = x_datas[function] as String
		else:
			f_name = y_labels[function]
		var legend_font: Font
		if font != null:
			legend_font = font
		if bold_font != null:
			legend_font = bold_font
		function_legend.create_legend(f_name, function_colors[function], bold_font, font_color)
		legend.append(function_legend)
