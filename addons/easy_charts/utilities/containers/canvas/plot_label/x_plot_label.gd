extends HSeparator


func _draw() -> void:
	var chart_properties: ChartProperties = get_owner().chart_properties
	
	var x_label: String = chart_properties.x_label
	var half_x_label_size: Vector2 = chart_properties.get_string_size(x_label) / 2.0
	var string_position: Vector2 = (get_rect().size / 2.0) + Vector2(-half_x_label_size.x, half_x_label_size.y)
	
	draw_string(
		chart_properties.font, string_position, x_label, HORIZONTAL_ALIGNMENT_CENTER, 
		-1, chart_properties.font_size, chart_properties.colors.text,
		TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL
	)
