extends ScatterPlotter
class_name LinePlotter

func _get_spline_points(density: float = 10.0, tension: float = 1) -> PoolVector2Array:
	var spline_points: PoolVector2Array = []
	
	var augmented: PoolVector2Array = self.points_positions
	var pi: Vector2 = augmented[0] - Vector2(10, -10)
	var pf: Vector2 = augmented[augmented.size() - 1] + Vector2(10, 10)
	
	augmented.insert(0, pi)
	augmented.push_back(pf)
	
	for p in range(1, augmented.size() - 2, 1) : #(inclusive)
		for f in range(0, density + 1, 1):
			spline_points.append(
				augmented[p].cubic_interpolate(
					augmented[p + 1], 
					augmented[p - 1], 
					augmented[p + 2], 
					f / density)
				)
	
	return spline_points

func _draw() -> void:
	match function.get_interpolation():
		Function.Interpolation.LINEAR:
			draw_polyline(
				points_positions, 
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
