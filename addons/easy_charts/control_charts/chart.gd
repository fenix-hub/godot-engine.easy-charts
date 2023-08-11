@icon("res://addons/easy_charts/utilities/icons/linechart.svg")
extends Control
class_name Chart

signal function_point_entered(point: Point, function: Function)
signal function_point_exited()

@onready var _canvas: Canvas = $Canvas
@onready var plot_box: PlotBox = $"%PlotBox"
@onready var grid_box: GridBox = $"%GridBox"
@onready var functions_box:  = $"%FunctionsBox"
@onready var function_legend: FunctionLegend = $"%FunctionLegend"
@onready var tooltip: DataTooltip = $Node/Tooltip

var functions: Array = []
var x: Array = []
var y: Array = []

var x_domain: Dictionary = {}
var y_domain: Dictionary = {}

var x_labels: PackedStringArray = []
var y_labels: PackedStringArray = []

var chart_properties: ChartProperties = ChartProperties.new()

###########

func setup_tree() -> void:
	theme.set("default_font", self.chart_properties.font)
	_canvas.prepare_canvas()


func _ready() -> void:
	pass


func plot(functions: Array[Function], properties: ChartProperties = ChartProperties.new()) -> void:
	self.functions = functions
	self.chart_properties = properties
	
	setup_tree()
	load_functions(functions)
	update()


func clear() -> void:
	_canvas.clear()
	plot_box.clear()
	grid_box.clear()
	functions_box.clear()
	function_legend.clear()

func load_functions(functions: Array[Function]) -> void:
	self.x = []
	self.y = []
	
	function_legend.clear()
	
	for function in functions:
		# Load x and y values
		self.x.append(function.x)
		self.y.append(function.y)
		
		# Load Labels
		if self.x_labels.is_empty():
			if ECUtilities._contains_string(function.x):
				self.x_labels = function.x
		
		# Create FunctionPlotter
		functions_box.add_function(function)
		
		# Create legend
		match function.get_type():
			Function.Type.PIE:
				for i in function.x.size():
					var interp_color: Color = function.get_gradient().sample(float(i) / float(function.x.size()))
					function_legend.add_label(function.get_type(), interp_color, Function.Marker.NONE, function.y[i])
			_:
				function_legend.add_function(function)

func calculate_domain(values: Array) -> Dictionary:
	for value_array in values:
		if ECUtilities._contains_string(value_array):
			return { lb = 0.0, ub = (value_array.size() - 1), has_decimals = false }
	var min_max: Dictionary = ECUtilities._find_min_max(values)
	return { lb = ECUtilities._round_min(min_max.min), ub = ECUtilities._round_max(min_max.max), has_decimals = ECUtilities._has_decimals(values) }

func update() -> void:
	x_domain = calculate_domain(x)
	y_domain = calculate_domain(y)
	
	plot_box.queue_redraw()
	grid_box.queue_redraw()
	functions_box.queue_redraw()


func _on_function_point_entered(point: Point, function: Function, props: Dictionary = {}) -> void:
	var x_value: String = point.value.x if point.value.x is String else ECUtilities._format_value(point.value.x, ECUtilities._is_decimal(point.value.x))
	var y_value: String = point.value.y if point.value.y is String else ECUtilities._format_value(point.value.y, ECUtilities._is_decimal(point.value.y))
	var color: Color = function.get_color() if function.get_type() != Function.Type.PIE \
		else function.get_gradient().sample(props.interpolation_index)
	tooltip.update_values(x_value, y_value, function.name, color)
	tooltip.update_position(functions_box.global_position + point.global_position)
	tooltip.show()
	function_point_entered.emit(point, function)

func _on_function_point_exited() -> void:
	tooltip.hide()
	function_point_exited.emit()
