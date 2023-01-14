extends ScatterChart
class_name LineChart

func _draw_line(from: Point, to: Point, function_index: int) -> void:
	draw_line(
		from.position, 
		to.position, 
		chart_properties.get_function_color(function_index), 
		chart_properties.line_width,
		true
		)

func _draw_lines() -> void:
	for function in function_points.size():
		for i in range(1, function_points[function].size()):
			_draw_line(function_points[function][i], function_points[function][i - 1], function)

func _draw() -> void:
	if chart_properties.lines:
		_draw_lines()
