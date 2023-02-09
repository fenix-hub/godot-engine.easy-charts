extends LinePlotter
class_name AreaPlotter

func _init(function: Function).(function) -> void:
	pass

func _draw_areas() -> void:
	var box: Rect2 = get_box()
	var fp_augmented: PoolVector2Array = []
	match function.get_interpolation():
		Function.Interpolation.LINEAR:
			fp_augmented = points_positions
		Function.Interpolation.STAIR:
			fp_augmented = _get_stair_points()
		Function.Interpolation.SPLINE:
			fp_augmented = _get_spline_points()
	
	fp_augmented.insert(0, Vector2(fp_augmented[0].x, box.end.y))
	fp_augmented.push_back(Vector2(fp_augmented[-1].x, box.end.y))
	
	var base_color: Color = function.get_color()
	var colors: PoolColorArray = []
	for point in fp_augmented:
		base_color.a = range_lerp(point.y, box.end.y, box.position.y, 0.0, 0.5)
		colors.push_back(base_color)
	draw_polygon(fp_augmented, colors)

func _draw() -> void:
	_draw_areas()
