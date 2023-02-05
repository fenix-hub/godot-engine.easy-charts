extends LinePlotter
class_name AreaPlotter

func _draw_areas() -> void:
	var box: Rect2 = get_parent().get_parent().get_plot_box()
	var fp_augmented: PoolVector2Array = []
	match function.get_interpolation():
		Function.Interpolation.SPLINE:
			fp_augmented = _get_spline_points()
		Function.Interpolation.LINEAR:
			fp_augmented = points_positions
	
	fp_augmented.push_back(Vector2(fp_augmented[-1].x, box.end.y))
	fp_augmented.push_back(Vector2(fp_augmented[0].x, box.end.y))
	
	var base_color: Color = function.get_color()
	var colors: PoolColorArray = []
	for point in fp_augmented:
		base_color.a = range_lerp(point.y, box.end.y, box.position.y, 0.0, 0.8)
		colors.push_back(base_color)
	draw_polygon(fp_augmented, colors)

func _draw() -> void:
	_draw_areas()
