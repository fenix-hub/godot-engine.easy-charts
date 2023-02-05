extends Control
class_name PlotBox

signal function_point_entered(point, function)
signal function_point_exited(point, function)
onready var tooltip: DataTooltip = $Tooltip

var focused_point: Point
var focused_function: Function

var box_margins: Vector2 # Margins relative to this rect, in order to make space for ticks and tick_labels
var plot_inner_offset: Vector2 = Vector2(15, 15) # How many pixels from the broders should the plot be

var chart_properties: ChartProperties

func get_box() -> Rect2:
	var box: Rect2 = get_rect()
	box.position.x += box_margins.x
#	box.position.y += box_margins.y
	box.end.x -= box_margins.x
	box.end.y -= box_margins.y
	return box

func get_plot_box() -> Rect2:
	var inner_box: Rect2 = get_box()
	inner_box.position.x += plot_inner_offset.x
	inner_box.position.y += plot_inner_offset.y
	inner_box.end.x -= plot_inner_offset.x * 2
	inner_box.end.y -= plot_inner_offset.y * 2
	return inner_box

func _on_point_entered(point: Point, function: Function, props: Dictionary = {}) -> void:
	self.focused_function = function
	var x_value: String = point.value.x if point.value.x is String else ECUtilities._format_value(point.value.x, ECUtilities._is_decimal(point.value.x))
	var y_value: String = point.value.y if point.value.y is String else ECUtilities._format_value(point.value.y, ECUtilities._is_decimal(point.value.y))
	var color: Color = function.get_color() if function.get_type() != Function.Type.PIE \
		else function.get_gradient().interpolate(props.interpolation_index)
	tooltip.show()
	tooltip.update_values(x_value, y_value, function.name, color)
	tooltip.update_position(point.position)
	emit_signal("function_point_entered", point, function)

func _on_point_exited(point: Point, function: Function) -> void:
	if function != self.focused_function:
		return
	tooltip.hide()
	emit_signal("function_point_exited", point, function)
