extends VSeparator


func _draw() -> void:
	var y_label: String = get_chart_properties().y_label
	var half_y_label_size: Vector2 = get_chart_properties().get_string_size(y_label) / 2.0
	var string_position: Vector2 = (get_rect().size / 2.0) 
	string_position.y += half_y_label_size.x / 2.0
	
	draw_set_transform(string_position, -PI/2.0)
	draw_string(
		get_chart_properties().font, Vector2.ZERO, y_label, HORIZONTAL_ALIGNMENT_CENTER, 
		-1, get_chart_properties().font_size, get_chart_properties().colors.text,
		TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL
	)

func get_chart_properties() -> ChartProperties:
	return get_owner().chart_properties
