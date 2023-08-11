extends ScatterPlotter
class_name LinePlotter

func _init(function: Function) -> void:
	super(function)

func _get_spline_points(density: float = 10.0, tension: float = 1) -> PackedVector2Array:
	var spline_points: PackedVector2Array = []
	
	var augmented: PackedVector2Array = get_points_positions()
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


func _get_stair_points() -> PackedVector2Array:
	var stair_points: PackedVector2Array = get_points_positions()
	
	for i in range(points.size() - 1, 0, -1):
		stair_points.insert(i, Vector2(stair_points[i].x, stair_points[i-1].y))
	
	return stair_points


func _draw() -> void:
	super._draw()
	
	if function.get_interpolation() == Function.Interpolation.NONE:
		return
	
	match function.get_interpolation():
		Function.Interpolation.LINEAR:
			var line: Line2D
			if get_child_count() == 0:
				line = Line2D.new()
				line.default_color = function.get_color()
				line.width = function.get_line_width()
				add_child(line)
			else:
				line = get_child(0)
			var points := get_points_positions()
			var tween = create_tween()
			for i in range(0, points.size() - 1):
				line.add_point(points[i])
				await get_tree().create_timer(0.5).timeout
#				if i < line.get_point_count():
#					var point_pos: Vector2 = line.get_point_position(i)
#					tween.chain().tween_method(
#						line.set_point_position.bind(i), point_pos, points[i], 0.05
#					)
#				else:
#					tween.chain().tween_method(
#						line.add_point, points[i], points[i + 1], 0.05
#					)
#			draw_polyline(
#				get_points_positions(), 
#				function.get_color(), 
#				function.get_line_width(),
#				true
#			)
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
