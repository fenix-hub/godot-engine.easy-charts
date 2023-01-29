extends ScatterChart
class_name LineChart

var splines: Array = []

func _draw_line(from: Point, to: Point, function_index: int) -> void:
	draw_line(
		from.position, 
		to.position, 
		chart_properties.get_function_color(function_index), 
		chart_properties.line_width,
		true
		)

func _calculate_splines() -> void:
	splines.clear()
	
	for function_i in function_points_pos.size():
		splines.append(_get_spline_points(function_points[function_i]))


func _get_spline_points(points: Array, density: float = 10.0, tension: float = 1) -> Array:
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
	
	return spline_points

func _draw_splines() -> void:
	for function_i in function_points_pos.size():
		draw_polyline(
			splines[function_i],
			chart_properties.get_function_color(function_i),
			chart_properties.line_width,
			true
		)

func _draw_lines() -> void:
	for function_i in function_points_pos.size():
		draw_polyline(
			function_points_pos[function_i], 
			chart_properties.get_function_color(function_i), 
			chart_properties.line_width,
			true
			)

func _draw() -> void:
	if chart_properties.use_splines:
		_calculate_splines()
		_draw_splines()
	else:
		_draw_lines()
