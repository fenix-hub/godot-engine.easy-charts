extends Control
class_name GridBox

var x_domain: ChartAxisDomain = null
var x_labels_function: Callable = Callable()
var x_labels_centered: bool = false

var y_domain: ChartAxisDomain = null
var y_labels_function: Callable = Callable()

var box: Rect2
var plot_box: Rect2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_domains(x_domain: ChartAxisDomain, y_domain: ChartAxisDomain) -> void:
	self.x_domain = x_domain
	self.y_domain = y_domain

func set_labels_functions(x_labels_function: Callable, y_labels_function: Callable) -> void:
	self.x_labels_function = x_labels_function
	self.y_labels_function = y_labels_function

func _draw() -> void:
	if get_parent().chart_properties == null:
		printerr("Cannot draw GridBox without ChartProperties!")
		return
	
	self.box = get_parent().get_box()
	self.plot_box = get_parent().get_plot_box()
	
	if get_parent().chart_properties.draw_background:
		_draw_background()
	
	if get_parent().chart_properties.draw_grid_box:
		_draw_x_ticks()
		_draw_y_ticks()
	
	if get_parent().chart_properties.draw_origin:
		_draw_origin()
	
	if get_parent().chart_properties.draw_bounding_box:
		_draw_bounding_box()

func _draw_background() -> void:
	var style_box := get_theme_stylebox("plot_area", "Chart")
	if style_box is StyleBoxFlat:
		draw_rect(self.box, style_box.bg_color, true)# false) TODOGODOT4 Antialiasing argument is missing
	elif style_box is StyleBoxEmpty:
		return
	else:
		push_error("plot_area style box must be StyleBoxFlat or StyleBoxEmpty")

func _draw_bounding_box() -> void:
	var box: Rect2 = self.box
	box.position.y += 1

	var style_box := get_theme_stylebox("plot_area", "Chart")
	if style_box is StyleBoxFlat:
		draw_rect(box, style_box.border_color, false, 1)# true) TODOGODOT4 Antialiasing argument is missing
	elif style_box is StyleBoxEmpty:
		return
	else:
		push_error("plot_area style box must be StyleBoxFlat or StyleBoxEmpty")

func _draw_origin() -> void:
	var xorigin: float = ECUtilities._map_domain(0.0, x_domain, ChartAxisDomain.from_bounds(self.plot_box.position.x, self.plot_box.end.x))
	var yorigin: float = ECUtilities._map_domain(0.0, y_domain, ChartAxisDomain.from_bounds(self.plot_box.end.y, self.plot_box.position.y))
	
	draw_line(Vector2(xorigin, self.plot_box.position.y), Vector2(xorigin, self.plot_box.position.y + self.plot_box.size.y), get_theme_color("origin_color", "Chart"), 1)
	draw_line(Vector2(self.plot_box.position.x, yorigin), Vector2(self.plot_box.position.x + self.plot_box.size.x, yorigin), get_theme_color("origin_color", "Chart"), 1)
	draw_string(
		get_parent().chart_properties.font, Vector2(xorigin, yorigin) - Vector2(15, -15), "O", HORIZONTAL_ALIGNMENT_CENTER, -1, 
		ThemeDB.fallback_font_size, get_theme_color("text_color", "Chart"), TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL
	)


func _draw_x_ticks() -> void:
	var labels = x_domain.get_tick_labels()
	var tick_count = labels.size()

	var x_pixel_dist: float = self.plot_box.size.x / tick_count
	
	var vertical_grid: PackedVector2Array = []
	var vertical_ticks: PackedVector2Array = []
	
	for i in range(tick_count):
		var x_position: float = (i * x_pixel_dist) + self.plot_box.position.x

		var top: Vector2 = Vector2(x_position, self.box.position.y)
		var bottom: Vector2 = Vector2(x_position, self.box.end.y)

		vertical_grid.append(top)
		vertical_grid.append(bottom)

		vertical_ticks.append(bottom)
		vertical_ticks.append(bottom + Vector2(0, get_parent().chart_properties.x_tick_size))

		# Draw x tick labels
		if get_parent().chart_properties.show_tick_labels:
			var label: String = labels[i]
			draw_string(
				get_parent().chart_properties.font, 
				_get_x_tick_label_position(bottom, label, x_pixel_dist),
				label,
				HORIZONTAL_ALIGNMENT_CENTER,
				-1,
				ThemeDB.fallback_font_size,
				get_theme_color("text_color", "Chart"),
				TextServer.JUSTIFICATION_NONE,
				TextServer.DIRECTION_AUTO,
				TextServer.ORIENTATION_HORIZONTAL
			)

	# Draw x grid
	if get_parent().chart_properties.draw_vertical_grid:
		draw_multiline(vertical_grid, get_theme_color("tick_grid_line_color", "Chart"), 1)

	# Draw x ticks
	if get_parent().chart_properties.draw_ticks:
		draw_multiline(vertical_ticks, get_theme_color("tick_color", "Chart"), 1)

func _draw_y_ticks() -> void:
	var labels = y_domain.get_tick_labels()
	var tick_count = labels.size()
	var y_pixel_dist: float = self.plot_box.size.y / tick_count

	var horizontal_grid: PackedVector2Array = []
	var horizontal_ticks: PackedVector2Array = []

	for i in range(tick_count):
		var y_sampled_val: float = self.plot_box.size.y - (i * y_pixel_dist) + self.plot_box.position.y

		var left: Vector2 = Vector2(self.box.position.x, y_sampled_val)
		var right: Vector2 = Vector2(self.box.end.x, y_sampled_val)

		horizontal_grid.append(left)
		horizontal_grid.append(right)

		horizontal_ticks.append(left)
		horizontal_ticks.append(left - Vector2(get_parent().chart_properties.y_tick_size, 0))

		# Draw y tick labels
		if get_parent().chart_properties.show_tick_labels:
			var label: String = labels[i]
			draw_string(
				get_parent().chart_properties.font,
				_get_y_tick_label_position(left, label),
				label,
				HORIZONTAL_ALIGNMENT_CENTER,
				-1,
				ThemeDB.fallback_font_size,
				get_theme_color("text_color", "Chart"),
				TextServer.JUSTIFICATION_NONE,
				TextServer.DIRECTION_AUTO,
				TextServer.ORIENTATION_HORIZONTAL
			)
	
	# Draw y grid
	if get_parent().chart_properties.draw_horizontal_grid:
		draw_multiline(horizontal_grid, get_theme_color("tick_grid_line_color", "Chart"), 1)
	
	# Draw y ticks
	if get_parent().chart_properties.draw_ticks:
		draw_multiline(horizontal_ticks, get_theme_color("tick_color", "Chart"), 1)
		

func _get_x_tick_label_position(base_position: Vector2, text: String, x_pixel_dist: float) -> Vector2:
	var x_offset: float = 0 if !x_labels_centered else 0.5 * x_pixel_dist

	return  base_position + Vector2(
		- get_parent().chart_properties.font.get_string_size(text).x / 2 + x_offset,
		ThemeDB.fallback_font_size + get_parent().chart_properties.x_tick_size
	)

func _get_y_tick_label_position(base_position: Vector2, text: String) -> Vector2:
	return base_position - Vector2(
		get_parent().chart_properties.font.get_string_size(text).x + get_parent().chart_properties.y_tick_size + get_parent().chart_properties.x_ticklabel_space, 
		- ThemeDB.fallback_font_size * 0.35
	)
