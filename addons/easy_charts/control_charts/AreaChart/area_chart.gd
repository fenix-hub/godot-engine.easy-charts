extends LineChart
class_name AreaChart

func _draw_areas() -> void:
	for function_i in function_points.size():
		var fp_augmented: PoolVector2Array = function_points_pos[function_i] \
			if not chart_properties.use_splines \
			else splines[function_i]
		var base_color: Color = chart_properties.get_function_color(function_i)
		var colors: PoolColorArray = []
		fp_augmented.insert(0, Vector2(fp_augmented[0].x, y_sampled_domain.left))
		fp_augmented.push_back(Vector2(fp_augmented[-1].x, y_sampled_domain.left))
		for point_i in fp_augmented.size():
			base_color.a = range_lerp(fp_augmented[point_i].y, y_sampled_domain.left, y_sampled_domain.right, 0.0, 0.8)
			colors.push_back(base_color)
		draw_polygon(fp_augmented, colors)

func _draw() -> void:
	_draw_areas()
