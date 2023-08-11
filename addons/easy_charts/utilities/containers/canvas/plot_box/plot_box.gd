extends PanelContainer
class_name PlotBox


var box_margins: Vector2 # Margins relative to this rect, in order to make space for ticks and tick_labels
var plot_inner_offset: Vector2 = Vector2(15, 15) # How many pixels from the broders should the plot be

func _ready() -> void:
	pass

func _draw() -> void:
	self.box_margins = calculate_margins(get_owner().x_domain, get_owner().y_domain)

func calculate_margins(x_domain: Dictionary, y_domain: Dictionary) -> Vector2:
	var chart_properties: ChartProperties = get_chart_properties()
	var plotbox_margins: Vector2 = Vector2(
		chart_properties.x_tick_size,
		chart_properties.y_tick_size
	)
	
	if chart_properties.show_tick_labels:
		var x_ticklabel_size: Vector2
		var y_ticklabel_size: Vector2
		
		var y_max_formatted: String = ECUtilities._format_value(y_domain.ub, y_domain.has_decimals)
		if y_domain.lb < 0: # negative number
			var y_min_formatted: String = ECUtilities._format_value(y_domain.lb, y_domain.has_decimals)
			if y_min_formatted.length() >= y_max_formatted.length():
				y_ticklabel_size = chart_properties.get_string_size(y_min_formatted)
			else:
				y_ticklabel_size = chart_properties.get_string_size(y_max_formatted)
		else:
			y_ticklabel_size = chart_properties.get_string_size(y_max_formatted)
		
		plotbox_margins.x += y_ticklabel_size.x + chart_properties.x_ticklabel_space
		plotbox_margins.y += ThemeDB.fallback_font_size + chart_properties.y_ticklabel_space
	
	return plotbox_margins

func get_box() -> Rect2:
	var box: Rect2 = get_rect()
	box.position.x += box_margins.x
#	box.position.y += box_margins.y
	box.end.x -= box_margins.x
	box.end.y -= box_margins.y
	return box

func get_plot_box() -> Rect2:
	var inner_box: Rect2 = get_box()
	inner_box.position.x += plot_inner_offset.x
	inner_box.position.y += plot_inner_offset.y
	inner_box.end.x -= plot_inner_offset.x * 2
	inner_box.end.y -= plot_inner_offset.y * 2
	return inner_box

# Meta
func get_chart_properties() -> ChartProperties:
	return get_owner().chart_properties
