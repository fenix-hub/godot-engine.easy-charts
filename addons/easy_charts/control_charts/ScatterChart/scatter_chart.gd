extends Chart
class_name ScatterChart

signal point_entered(point)

var _point_box_rad: int = 10

# List of all unordered points belonging to this plot
var points: Array = []

# List of all points, grouped by function
var function_points: Array = []
var function_points_pos: Array = []

# Currently focused point
var focused_point: Point = null

func _get_point_box(point: Point, rad: int) -> Rect2:
	return Rect2(point.position - (Vector2.ONE * rad), (Vector2.ONE * rad * 2))

func _get_function_point(point: Point) -> int:
	var point_f_index: int = -1
	for f_point in function_points.size():
		var found: int = function_points[f_point].find(point)
		if found != -1:
			point_f_index = f_point
			break
	return point_f_index

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		for point in points:
			if _get_point_box(point, _point_box_rad).abs().has_point(event.position):
				if focused_point == point:
					return
				else:
					focused_point = point
					var func_index: int = _get_function_point(focused_point)
					$Tooltip.update_values(
						str(point.value.left),
						str(point.value.right),
						chart_properties.get_function_name(func_index),
						chart_properties.get_function_color(func_index)
					)
					$Tooltip.show()
					emit_signal("point_entered", point)
					return
		# Mouse is not in any point's box
		focused_point = null
		$Tooltip.hide()

func _draw_point(point: Point, function_index: int) -> void:
	match chart_properties.get_point_shape(function_index):
		Point.Shape.CIRCLE:
			draw_circle(point.position, chart_properties.point_radius,  chart_properties.get_function_color(function_index))
		Point.Shape.SQUARE:
			draw_rect(_get_point_box(point, chart_properties.point_radius), chart_properties.get_function_color(function_index), true, 1.0, false)
		Point.Shape.TRIANGLE:
			draw_colored_polygon(
				PoolVector2Array([
					point.position + (Vector2.UP * chart_properties.point_radius * 1.3),
					point.position + (Vector2.ONE * chart_properties.point_radius * 1.3),
					point.position - (Vector2(1, -1) * chart_properties.point_radius * 1.3)
				]), chart_properties.get_function_color(function_index), [], null, null, false
			)
		Point.Shape.CROSS:
			draw_line(
				point.position - (Vector2.ONE * chart_properties.point_radius),
				point.position + (Vector2.ONE * chart_properties.point_radius),
				chart_properties.get_function_color(function_index), chart_properties.point_radius, true
			)
			draw_line(
				point.position + (Vector2(1, -1) * chart_properties.point_radius),
				point.position + (Vector2(-1, 1) * chart_properties.point_radius),
				chart_properties.get_function_color(function_index), chart_properties.point_radius / 2, true
			)
	
#	# (debug)
#	draw_rect(
#		_get_point_box(point, _point_box_rad),
#		Color.red,
#		false, 1, true
#	)

func _draw_points() -> void:
	for function in function_points.size():
		for point in function_points[function]:
			_draw_point(point, function)

func _calculate_points() -> void:
	var validation: int = _validate_sampled_axis(x_sampled, y_sampled)
	if not validation == OK:
		printerr("Cannot plot points for invalid dataset! Error: %s" % validation)
		return
	
	points.clear()
	function_points.clear()
	function_points_pos.clear()
	
	if y_sampled.values[0] is Array:
		for yxi in y_sampled.values.size():
			var _function_points: Array = []
			var _function_points_pos: PoolVector2Array = []
			for i in y_sampled.values[yxi].size():
				var real_point_val: Pair = Pair.new(x[i], y[yxi][i])
				var sampled_point_pos: Vector2 = Vector2(x_sampled.values[i], y_sampled.values[yxi][i])
				var point: Point = Point.new(sampled_point_pos, real_point_val)
				_function_points.append(point)
				_function_points_pos.append(sampled_point_pos)
				points.append(point)
			function_points.append(_function_points)
			function_points_pos.append(_function_points_pos)
	else:
		var _function_points_pos: PoolVector2Array = []
		for i in y_sampled.values.size():
			var real_point_val: Pair = Pair.new(x[i], y[i])
			var sampled_point_pos: Vector2 = Vector2(x_sampled.values[i], y_sampled.values[i])
			var point: Point = Point.new(sampled_point_pos, real_point_val)
			points.append(point)
			_function_points_pos.push_back(point.position)
		function_points.append(points)
		function_points_pos.append(_function_points_pos)

func _draw() -> void:
	_calculate_points()
	
	if chart_properties.points:
		_draw_points()
