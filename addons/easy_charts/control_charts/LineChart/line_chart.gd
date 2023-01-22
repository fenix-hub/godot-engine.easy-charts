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

func _draw_spline(points: Array, function: int, density: float = 10.0, tension: float = 1) -> void:
	var spline_points: Array = []
	
	var augmented: Array = points.duplicate(true)
	var pi: Point = Point.new(points.front().position - Vector2(10, -10), Pair.new())
	var pf: Point = Point.new(points.back().position + Vector2(10, 10), Pair.new())
	
	augmented.insert(0, pi)
	augmented.append(pf)
	
	for p in range(1, augmented.size() - 2, 1) : #(inclusive)
		
		for f in range(0, density + 1, 1):
			spline_points.append(
				augmented[p].position.cubic_interpolate(
					augmented[p + 1].position, 
					augmented[p - 1].position, 
					augmented[p + 2].position, 
					f / density)
				)
	
	for i in range(1, spline_points.size()):
		draw_line(spline_points[i-1], spline_points[i], chart_properties.get_function_color(function), chart_properties.line_width, true)

func _draw_lines() -> void:
	for function in function_points.size():
		if chart_properties.use_splines:
			_draw_spline(function_points[function], function)
		else:
			for i in range(1, function_points[function].size()):
				_draw_line(function_points[function][i - 1], function_points[function][i], function)

func _draw() -> void:
	_draw_lines()
