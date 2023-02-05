extends FunctionPlotter
class_name ScatterPlotter

func _draw() -> void:
	if function.get_marker() != Function.Marker.NONE:
		for point in points:
			draw_function_point(point.position)

func draw_function_point(position: Vector2) -> void:
	match function.get_marker():
		Function.Marker.SQUARE:
			draw_rect(
				Rect2(position - (Vector2.ONE * point_size), (Vector2.ONE * point_size * 2)), 
				function.get_color(), true, 1.0, false
			)
		Function.Marker.TRIANGLE:
			draw_colored_polygon(
				PoolVector2Array([
					position + (Vector2.UP * point_size * 1.3),
					position + (Vector2.ONE * point_size * 1.3),
					position - (Vector2(1, -1) * point_size * 1.3)
				]), function.get_color(), [], null, null, false
			)
		Function.Marker.CROSS:
			draw_line(
				position - (Vector2.ONE * point_size),
				position + (Vector2.ONE * point_size),
				function.get_color(), point_size, true
			)
			draw_line(
				position + (Vector2(1, -1) * point_size),
				position + (Vector2(-1, 1) * point_size),
				function.get_color(), point_size / 2, true
			)
		_, Function.Marker.CIRCLE:
			draw_circle(position, point_size, function.get_color())

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		for point in points:
			if Geometry.is_point_in_circle(event.position - rect_global_position, point.position, self.point_size * 4):
				if focused_point == point:
					return
				else:
					focused_point = point
					emit_signal("point_entered", point, function)
					return
		# Mouse is not in any point's box
		emit_signal("point_exited", focused_point, function)
		focused_point = null
