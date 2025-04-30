extends ScatterPlotter
class_name LinePlotter

func _get_spline_points(density: float = 10.0, tension: float = 1) -> PackedVector2Array:
	var spline_points: PackedVector2Array = []
	
	var point_positions: PackedVector2Array = points_positions
	var pi: Vector2 = points_positions[0] - Vector2(10, -10)
	var pf: Vector2 = point_positions[point_positions.size() - 1] + Vector2(10, 10)

	point_positions.insert(0, pi)
	point_positions.push_back(pf)
	
	for p in range(1, point_positions.size() - 2, 1) : #(inclusive)
		for f in range(0, density + 1, 1):
			spline_points.append(
				point_positions[p].cubic_interpolate(
					point_positions[p + 1], 
					point_positions[p - 1], 
					point_positions[p + 2], 
					f / density)
				)
	
	return spline_points


func _get_stair_points() -> PackedVector2Array:
	var 	stair_points: PackedVector2Array = points_positions
	
	for i in range(points_positions.size() - 1, 0, -1):
		stair_points.insert(i, Vector2(points_positions[i].x, points_positions[i-1].y))
	
	return stair_points


func _draw() -> void:
	super._draw()
	
	#prevent error when drawing with no data.
	if points_positions.size() < 2:
		printerr("Cannot plot a line with less than two points!")
		return
	
	match function.get_interpolation():
		Function.Interpolation.LINEAR:
			draw_polyline(
				points_positions, 
				function.get_color(), 
				function.get_line_width(),
				true
			)
		Function.Interpolation.STAIR:
			draw_polyline(
				_get_stair_points(),
				function.get_color(),
				function.get_line_width(),
				true
			)
		Function.Interpolation.SPLINE:
			draw_polyline(
				_get_spline_points(), 
				function.get_color(), 
				function.get_line_width(),
				true
			)
		Function.Interpolation.NONE, _:
			pass
