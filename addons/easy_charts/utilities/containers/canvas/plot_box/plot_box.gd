extends Control
class_name PlotBox

# TODO: These signals have been removed. If anyone needs them, we can bring
# them back, but from the Chart, not from the PlotBox.
#signal function_point_entered(point, function)
#signal function_point_exited(point, function)

var focused_point: Point
var focused_function: Function

var box_margins: Vector2 # Margins relative to this rect, in order to make space for ticks and tick_labels
var plot_inner_offset: Vector2 = Vector2(15, 15) # How many pixels from the broders should the plot be

# TODO: Remove
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
