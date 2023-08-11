extends Control
class_name FunctionPlotter

var function: Function
var x_domain: Dictionary
var y_domain: Dictionary

func _init(function: Function) -> void:
	self.function = function

func _ready() -> void:
#	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(get_chart_properties().interactive)

func update_values(x_domain: Dictionary, y_domain: Dictionary) -> void:
	pass

func _draw() -> void:
	pass

func get_box() -> Rect2:
	return get_parent().get_parent().get_plot_box()

func get_chart_properties() -> ChartProperties:
	return get_parent().get_parent().get_chart_properties()

func get_relative_position(position: Vector2) -> Vector2:
	return position - global_position
