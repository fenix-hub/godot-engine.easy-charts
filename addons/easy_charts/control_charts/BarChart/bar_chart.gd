extends Chart
class_name BarChart

signal bar_entered(bar)

# Size of a horizontal vector, which is calculated by `plot_box.size.x / x.size()`
var x_sector_size: float

# List of all unordered bars belonging to this plot
var bars: Array = []

# List of all bars, grouped by function
var function_bars: Array = []
var function_bars_pos: Array = []

# Currently focused bar
var focused_bar: Bar = null


func _draw() -> void:
	# Draw Bars
	_calculate_bars()
	_draw_bars()

func _calc_x_domain() -> void:
	pass

func _sample_x() -> void:
	### @sampled_domain, which are the domain relative to the sampled values
	### x (real value) --> sampling --> x_sampled (pixel value in canvas)
	x_sampled_domain = Pair.new(plot_box.position.x, plot_box.end.x)
	
	# samples
	x_sampled = SampledAxis.new(x, x_sampled_domain)
	
	x_sector_size = (x_sampled_domain.right - x_sampled_domain.left) / x.size()

func sort_ascending(a: String, b: String):
	if a.length() < b.length():
		return true
	return false

func _find_longest_x() -> String:
	var longest_x: String = ""
	var x_str: Array = x.duplicate(true)
	x_str.sort_custom(self, "sort_ascending")
	return x_str.back()


func _draw_bar(bar: Bar, function_index: int) -> void:
	draw_rect(
		bar.rect, 
		chart_properties.get_function_color(function_index),
		true,
		1,
		false
	)

func _draw_bars() -> void:
	for function in function_bars.size():
		for i in range(0, function_bars[function].size()):
			_draw_bar(
				function_bars[function][i],
				function
			)

func _get_tick_label(line_index: int, line_value: float) -> String:
	return x[line_index]

func _get_vertical_tick_label_pos(base_position: Vector2, text: String) -> Vector2:
	return ._get_vertical_tick_label_pos(base_position, text) + Vector2(x_sector_size / 2, 0)


func _draw_vertical_grid() -> void:
	# draw vertical lines

	# 1. the amount of lines is equals to the X_scale: it identifies in how many sectors the x domain
	#    should be devided
	# 2. calculate the spacing between each line in pixel. It is equals to x_sampled_domain / x_scale
	# 3. calculate the offset in the real x domain, which is x_domain / x_scale.
	
	var vertical_grid: Array = []
	var vertical_ticks: Array = []
	for _x in x.size():
		var top: Vector2 = Vector2(
			(_x * x_sector_size) + plot_box.position.x,
			bounding_box.position.y
		)
		var bottom: Vector2 = Vector2(
			(_x * x_sector_size) + plot_box.position.x,
			bounding_box.end.y
		)
		vertical_grid.append(top)
		vertical_grid.append(bottom)
		
		vertical_ticks.append(bottom)
		vertical_ticks.append(bottom + Vector2(0, _x_tick_size))
		
		# Draw V Tick Labels
		if chart_properties.labels:
			var tick_lbl: String = x[_x]
			draw_string(
				chart_properties.font, 
				_get_vertical_tick_label_pos(bottom, tick_lbl),
				tick_lbl, 
				chart_properties.colors.bounding_box
			)
	
	### Draw last gridline
	var top: Vector2 = Vector2(
		(x.size() * x_sector_size) + plot_box.position.x,
		bounding_box.position.y
	)
	vertical_grid.append(top)
	
	var bottom: Vector2 = Vector2(
		(x.size() * x_sector_size) + plot_box.position.x,
		bounding_box.end.y
	)
	vertical_grid.append(bottom)
	vertical_ticks.append(bottom)
	vertical_ticks.append(bottom + Vector2(0, _x_tick_size))
	
	# Draw V Grid Lines
	if chart_properties.grid:
		draw_multiline(vertical_grid, chart_properties.colors.grid, 1, true)
	
	# Draw V Ticks
	if chart_properties.ticks:
		draw_multiline(vertical_ticks, chart_properties.colors.bounding_box, 1, true)


func _calculate_bars() -> void:
	var validation: int = _validate_sampled_axis(x_sampled, y_sampled)
	if not validation == OK:
		printerr("Cannot plot bars for invalid dataset! Error: %s" % validation)
		return
	
	bars.clear()
	function_bars.clear()
	function_bars_pos.clear()
	
	if y_sampled.values[0] is Array:
		for yxi in y_sampled.values.size():
			var _function_bars: Array = []
			for i in y_sampled.values[yxi].size():
				var real_bar_value: Pair = Pair.new(x[i], y[yxi][i])
				var center_bar_pos: Vector2 = Vector2(
					(x_sector_size * i) + (x_sector_size / 2) + x_sampled_domain.left,
					y_sampled.values[yxi][i]
				)
				var sampled_bar_pos: Vector2 = center_bar_pos - Vector2(
					chart_properties.bar_width / 2, 
					0
				)
				var sampled_bar_size: Vector2 = Vector2(
					chart_properties.bar_width,
					y_sampled_domain.left - y_sampled.values[yxi][i]
				)
				var bar: Bar = Bar.new(Rect2(sampled_bar_pos, sampled_bar_size), real_bar_value)
				_function_bars.append(bar)
				bars.append(bar)
			function_bars.append(_function_bars)
	else:
		for i in y_sampled.values.size():
			var real_bar_value: Pair = Pair.new(x[i], y[i])
			var center_bar_pos: Vector2 = Vector2(
				(x_sector_size * i) + (x_sector_size / 2) + x_sampled_domain.left,
				y_sampled.values[i]
			)
			var sampled_bar_pos: Vector2 = center_bar_pos - Vector2(
				chart_properties.bar_width / 2, 
				0
			)
			var sampled_bar_size: Vector2 = Vector2(
				chart_properties.bar_width,
				y_sampled_domain.left - y_sampled.values[i]
			)
			var bar: Bar = Bar.new(Rect2(sampled_bar_pos, sampled_bar_size), real_bar_value)
			bars.append(bar)
		function_bars.append(bars)


func _get_function_bar(bar: Bar) -> int:
	var bar_f_index: int = -1
	for f_bar in function_bars.size():
		var found: int = function_bars[f_bar].find(bar)
		if found != -1:
			bar_f_index = f_bar
			break
	return bar_f_index

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		for bar in bars:
			if bar.rect.abs().has_point(event.position):
				if focused_bar == bar:
					return
				else:
					focused_bar = bar
					var func_index: int = _get_function_bar(focused_bar)
					$Tooltip.update_values(
						str(focused_bar.value.left),
						str(focused_bar.value.right),
						chart_properties.get_function_name(func_index),
						chart_properties.get_function_color(func_index)
					)
					$Tooltip.show()
					emit_signal("bar_entered", bar)
					return
		# Mouse is not in any bar's box
		focused_bar = null
		$Tooltip.hide()
