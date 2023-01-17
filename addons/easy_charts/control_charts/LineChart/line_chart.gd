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

#func u(t) -> float:
#	return pow(1.0 - t, 2) / (pow(t, 2) + pow(1.0 - t, 2))
#
#func ratio(t: float) -> float:
#	return abs((pow(t, 2) + pow(1.0 - t, 2) - 1.0) / (pow(t, 2) + pow(1.0 - t, 2)))
#
#func find_a(B: Vector2, C: Vector2, t: float) -> Vector2:
#	return B + ((B - C) / ratio(t))
#
#func find_c(P0: Vector2, P2: Vector2, t: float) -> Vector2:
#	return (u(t) * P0) + ((1.0 - u(t)) * P2)
#
#func _bezier(P0: Vector2, P1: Vector2, P2: Vector2, w: float) -> Vector2:
#	return (pow(1.0 - w, 2) * P0) + (2.0 * w * (1.0 - w) * P1) + (pow(w, 2) * P2)
#
#func find_t(P0: Vector2, P1: Vector2, P2: Vector2) -> float:
#	return abs(P0.distance_to(P1)) / (abs(P0.distance_to(P1)) + abs(P2.distance_to(P1)))
#
#func _draw_spline(p1: Point, p2: Point, p3: Point) -> void:
#	var t: float = find_t(p1.position, p2.position, p3.position)
#	var c: Vector2 = find_c(p1.position, p3.position, t)
#	var a: Vector2 = find_a(p2.position, c, t)
#	for j in 101:
#		var bezier1: Vector2 = _bezier(p1.position, a, p3.position, (j / 100.0) - 0.01)
#		var bezier2: Vector2 = _bezier(p1.position, a, p3.position, j / 100.0)
#		draw_line(bezier1, bezier2, Color.black, 1, true)

# Draw a B-Spline using the Catmull-Rom method
# Also, add a fake starting and ending point to complete the beginning and the end of the spline
# @points = a list of at least 4 coordinates
# @tension = some value greater than 0, defaulting to 1
func _draw_spline(points: Array, function: int, density: float = 10.0, tension: float = 1) -> void:
	var spline_points: Array = []
	
	var augmented: Array = points.duplicate(true)
	var pi: Point = Point.new(points.front().position - Vector2(10, -10), Pair.new())
	var pf: Point = Point.new(points.back().position + Vector2(10, 10), Pair.new())
	
	augmented.insert(0, pi)
	augmented.append(pf)
	
	for p in range(1, augmented.size() - 2, 1) : #(inclusive)
		var p0: Vector2 = augmented[p - 1].position
#	  v1 = p1 = augmented[p]
		var p1: Vector2 = augmented[p].position
		var v1: Vector2 = p1
#	  v2 = p2 = augmented[p+1]
		var p2: Vector2 = augmented[p + 1].position
		var v2: Vector2 = p2
		var p3: Vector2 = augmented[p + 2].position
		
		var s: int = 2.0 * tension
		var dv1: Vector2 = (p2 - p0) / s
		var dv2: Vector2 = (p3 - p1) / s
		
		for f in range(0, density + 1, 1):
			var t: float = f / density
			var c0: float = (2.0 * pow(t, 3)) - (3.0 * pow(t,2)) + 1.0
			var c1: float = pow(t, 3) - (2.0 * pow(t, 2)) + t
			var c2: float = (-2.0 * pow(t, 3)) + (3.0 * pow(t, 2))
			var c3: float = pow(t, 3) - pow(t, 2)
			var crp: Vector2 = (c0 * v1 + c1 * dv1 + c2 * v2 + c3 * dv2)
#			draw_circle(crp, 4, Color.magenta)
			spline_points.append(crp)
	
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
	if chart_properties.lines:
		_draw_lines()
