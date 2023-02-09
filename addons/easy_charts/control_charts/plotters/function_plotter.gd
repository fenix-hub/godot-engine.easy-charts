extends Control
class_name FunctionPlotter

var function: Function
var x_domain: Dictionary
var y_domain: Dictionary
var index: int

func _init(function: Function) -> void:
	self.function = function

func _ready() -> void:
	index = get_parent().get_child_count()
	set_process_input(get_chart_properties().interactive)

func update_values(x_domain: Dictionary, y_domain: Dictionary) -> void:
	self.x_domain = x_domain
	self.y_domain = y_domain
	update()

func _draw() -> void:
	pass

func get_box() -> Rect2:
	return get_parent().get_parent().get_box()

func get_plot_box() -> Rect2:
	return get_parent().get_parent().get_plot_box()

func get_chart_properties() -> ChartProperties:
	return get_parent().get_parent().chart_properties

func get_relative_position(position: Vector2) -> Vector2:
	return position - rect_global_position

func get_functions_count() -> int:
	return get_parent().get_child_count()
