extends HSeparator


func _draw() -> void:
	var title: String = get_chart_properties().title
	var half_title_size: Vector2 = get_chart_properties().get_string_size(title) / 2.0
	var string_position: Vector2 = (get_rect().size / 2.0) + Vector2(-half_title_size.x, half_title_size.y)
	
	draw_string(
		get_chart_properties().font, string_position, title, HORIZONTAL_ALIGNMENT_CENTER, 
		-1, get_chart_properties().font_size, get_chart_properties().colors.text,
		TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL
	)

func get_chart_properties() -> ChartProperties:
	return get_owner().chart_properties
