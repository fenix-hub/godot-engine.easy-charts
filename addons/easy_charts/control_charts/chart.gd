extends Control
class_name Chart

var x: Array
var y: Array

var x_min_max: Pair = Pair.new() # Min and Max values of @x
var x_domain: Pair = Pair.new()  # Rounded domain of values of @x
var y_min_max: Pair = Pair.new() # Min and Max values of @y
var y_domain: Pair = Pair.new()  # Rounded domain of values of @x

var x_sampled: SampledAxis = SampledAxis.new()
var y_sampled: SampledAxis = SampledAxis.new()

var x_labels: Array = []
var y_labels: Array = []
var functions_names: Array = []

###### STYLE
var chart_properties: ChartProperties = ChartProperties.new()

#### INTERNAL
# The bounding_box of the chart
var node_box: Rect2
var bounding_box: Rect2
var plot_offset: Vector2
var plot_box: Rect2

# The Reference Rectangle to plot samples
# It is the @bounding_box Rectangle inverted on the Y axis
var x_sampled_domain: Pair
var y_sampled_domain: Pair

var _padding_offset: Vector2 = Vector2(20.0, 20.0)
var _internal_offset: Vector2 = Vector2(15.0, 15.0)

var y_has_decimals: bool
var _y_label_size: Vector2 = Vector2.ZERO # offset only on the X axis
var _y_label_offset: int = 15 # offset only on the X axis
var _y_ticklabel_size: Vector2 # offset only on the X axis
var _y_ticklabel_offset: int = 5 # offset only on the X axis
var _y_tick_size: int = 7

var x_has_decimals: bool
var _x_label_size: Vector2 = Vector2.ZERO # offset only on the X axis
var _x_label_offset: int = 15 # offset only on the X axis
var _x_ticklabel_size: Vector2 # offset only on the X axis
var _x_ticklabel_offset: int = 5 # offset only on the X axis
var _x_tick_size: int = 7

###########
func _ready() -> void:
	set_process_input(false)
	set_process(false)

func validate_input_samples(samples: Array) -> bool:
	if samples.size() > 1 and samples[0] is Array:
		for sample in samples:
			if (not sample is Array) or sample.size() != samples[0].size():
				return false
	return true

func plot(x: Array, y: Array, properties: ChartProperties = self.chart_properties) -> void:
	self.x = x
	self.y = y
	
	if properties != null:
		self.chart_properties = properties
	
	set_process_input(chart_properties.interactive)
	
	update()

func _map_pair(val: float, rel: Pair, ref: Pair) -> float:
	return range_lerp(val, rel.left, rel.right, ref.left, ref.right)

func _has_decimals(values: Array) -> bool:
	var temp: Array = values.duplicate(true)
	
	if temp[0] is Array:
		for dim in temp:
			for val in dim:
				if val is String:
					return false
				if abs(fmod(val, 1)) > 0.0:
					 return true
	else:
		for val in temp:
			if val is String:
				return false
			if abs(fmod(val, 1)) > 0.0:
				 return true
	
	return false

func _find_min_max(values: Array) -> Pair:
	var temp: Array = values.duplicate(true)
	var _min: float
	var _max: float
	
	if temp[0] is Array:
		var min_ts: Array
		var max_ts: Array
		for dim in temp:
			min_ts.append(dim.min())
			max_ts.append(dim.max())
		_min = min_ts.min()
		_max = max_ts.max()
	else:
		_min = temp.min()
		_max = temp.max()
	
	return Pair.new(_min, _max)

func _sample_values(values: Array, rel_values: Pair, ref_values: Pair) -> SampledAxis:
	if values.empty():
		printerr("Trying to plot an empty dataset!")
		return SampledAxis.new()
	
	if values[0] is Array:
		if values.size() > 1:
			for dim in values:
				if values[0].size() != dim.size():
					printerr("Cannot plot a dataset with dimensions of different size!")
					return SampledAxis.new()
	
	var temp: Array = values.duplicate(true)
	
	var rels: Array = []
	var division_size: float
	if temp[0] is Array:
		for t_dim in temp:
			var rels_t: Array = []
			for val in t_dim:
				rels_t.append(_map_pair(val, rel_values, ref_values))
			rels.append(rels_t)
		
	else:
		division_size = (ref_values.right - ref_values.left) / values.size()
		for val_i in temp.size():
			if temp[val_i] is String:
				rels.append(val_i * division_size)
			else:
				rels.append(_map_pair(temp[val_i], rel_values, ref_values))
	
	return SampledAxis.new(rels, rel_values)

func _round_min(val: float) -> float:
	return round(val) if abs(val) < 10 else floor(val / 10.0) * 10.0

func _round_max(val: float) -> float:
	return round(val) if abs(val) < 10 else ceil(val / 10.0) * 10.0


func _calc_x_domain() -> void:
	x_min_max = _find_min_max(x)
	x_domain = Pair.new(_round_min(x_min_max.left), _round_max(x_min_max.right))

func _sample_x() -> void:
	### @sampled_domain, which are the domain relative to the sampled values
	### x (real value) --> sampling --> x_sampled (pixel value in canvas)
	x_sampled_domain = Pair.new(plot_box.position.x, plot_box.end.x)
	
	# samples
	x_sampled = _sample_values(x, x_min_max, x_sampled_domain)

func _calc_y_domain() -> void:
	y_min_max = _find_min_max(y)
	y_domain = Pair.new(_round_min(y_min_max.left), _round_max(y_min_max.right))

func _sample_y() -> void:
	### @sampled_domain, which are the domain relative to the sampled values
	### x (real value) --> sampling --> x_sampled (pixel value in canvas)
	y_sampled_domain = Pair.new(plot_box.end.y, plot_box.position.y)
	
	# samples
	y_sampled = _sample_values(y, y_domain, y_sampled_domain)


func _find_longest_x() -> String:
	return ("%.2f" if x_has_decimals else "%s") % x_domain.right

func _pre_process() -> void:
	_calc_x_domain()
	_calc_y_domain()
	
	var frame: Rect2 = get_global_rect()
	
	
	#### @node_box size, which is the whole "frame"
	node_box = Rect2(Vector2.ZERO, frame.size - frame.position)
	
	#### calculating offset from the @node_box for the @bounding_box.
	plot_offset = _padding_offset
	
	### if @labels drawing is enabled, calcualte offsets
	if chart_properties.labels:
		### labels (X, Y, Title)
		_x_label_size = chart_properties.font.get_string_size(chart_properties.x_label)
		_y_label_size = chart_properties.font.get_string_size(chart_properties.y_label)
		
		### tick labels
		
		###### --- X
		x_has_decimals = _has_decimals(x)
		# calculate the string length of the largest value on the X axis.
		# remember that "-" sign adds additional pixels, and it is relative only to negative numbers!
		var x_max_formatted: String = _find_longest_x()
		_x_ticklabel_size = chart_properties.font.get_string_size(x_max_formatted)
		
		plot_offset.y += _x_label_offset + _x_label_size.y + _x_ticklabel_offset + _x_ticklabel_size.y
		
		###### --- Y
		y_has_decimals = _has_decimals(y)
		# calculate the string length of the largest value on the Y axis.
		# remember that "-" sign adds additional pixels, and it is relative only to negative numbers!
		var y_max_formatted: String = ("%.2f" if y_has_decimals else "%s") % y_domain.right
		if y_domain.left < 0:
			# negative number
			var y_min_formatted: String = ("%.2f" if y_has_decimals else "%s") % y_domain.left
			if y_min_formatted.length() >= y_max_formatted.length():
				 _y_ticklabel_size = chart_properties.font.get_string_size(y_min_formatted)
			else:
				_y_ticklabel_size = chart_properties.font.get_string_size(y_max_formatted)
		else:
			_y_ticklabel_size = chart_properties.font.get_string_size(y_max_formatted)
		
		plot_offset.x += _y_label_offset + _y_label_size.y + _y_ticklabel_offset + _y_ticklabel_size.x
	
	### if @ticks drawing is enabled, calculate offsets
	if chart_properties.ticks:
		plot_offset.x += _y_tick_size
		plot_offset.y += _x_tick_size
	
	### @bounding_box, where the points will be plotted
	bounding_box = Rect2(
		plot_offset, 
		frame.size - (plot_offset * 2)
	)
	
	plot_box = Rect2(
		bounding_box.position + _internal_offset,
		bounding_box.size - (_internal_offset * 2)
	)
	
	_sample_x()
	_sample_y()

func _draw_borders() -> void:
	draw_rect(node_box, Color.red, false, 1, true)

func _draw_bounding_box() -> void:
	draw_rect(bounding_box, chart_properties.colors.bounding_box, false, 1, true)
	
#	# (debug)
#	var half: Vector2 = (bounding_box.size) / 2
#	draw_line(bounding_box.position + Vector2(half.x, 0), bounding_box.position + Vector2(half.x, bounding_box.size.y), Color.red, 3, false)
#	draw_line(bounding_box.position + Vector2(0, half.y), bounding_box.position + Vector2(bounding_box.size.x, half.y), Color.red, 3, false)

func _draw_origin() -> void:
	var xorigin: float = _map_pair(0.0, x_min_max, x_sampled_domain)
	var yorigin: float = _map_pair(0.0, y_domain, y_sampled_domain)
	draw_line(Vector2(xorigin, bounding_box.position.y), Vector2(xorigin, bounding_box.position.y + bounding_box.size.y), Color.black, 1, 0)
	draw_line(Vector2(bounding_box.position.x, yorigin), Vector2(bounding_box.position.x + bounding_box.size.x, yorigin), Color.black, 1, 0)
	draw_string(chart_properties.font, Vector2(xorigin, yorigin) - Vector2(15, -15), "O", chart_properties.colors.bounding_box)

func _draw_background() -> void:
	draw_rect(node_box, Color.white, true, 1.0, false)
	
#	# (debug)
#	var half: Vector2 = node_box.size / 2
#	draw_line(Vector2(half.x, node_box.position.y), Vector2(half.x, node_box.size.y), Color.red, 3, false)
#	draw_line(Vector2(node_box.position.x, half.y), Vector2(node_box.size.x, half.y), Color.red, 3, false)

func _draw_tick(from: Vector2, to: Vector2, color: Color) -> void:
	draw_line(from, to, color, 1, true)


func _get_vertical_tick_label_pos(base_position: Vector2, text: String) -> Vector2:
	return  base_position + Vector2(
		- chart_properties.font.get_string_size(text).x / 2,
		_x_label_size.y + _x_tick_size
	)

func _get_tick_label(line_index: int, line_value: float) -> String:
	var tick_lbl: String = ""
	if x_labels.empty():
		tick_lbl = ("%.2f" if x_has_decimals else "%s") % [x_min_max.left + (line_index * line_value)]
	else:
		tick_lbl = x_labels[clamp(line_value * line_index, 0, x_labels.size() - 1)]
	
	return tick_lbl

func _draw_vertical_gridline_component(p1: Vector2, p2: Vector2, line_index: int, line_value: float) -> void:
	if chart_properties.labels:
		var tick_lbl: String = _get_tick_label(line_index, line_value)
		draw_string(
			chart_properties.font, 
			_get_vertical_tick_label_pos(p2, tick_lbl),
			tick_lbl, 
			chart_properties.colors.bounding_box
		)
	
	# Draw V Ticks
	if chart_properties.ticks:
		_draw_tick(p2, p2 + Vector2(0, _x_tick_size), chart_properties.colors.bounding_box)
	
	# Draw V Grid Lines
	if chart_properties.grid:
		draw_line(p1, p2, chart_properties.colors.grid, 1, true)


func _draw_horizontal_tick_label(font: Font, position: Vector2, color: Color, line_index: int, line_value: float) -> void:
	var tick_lbl: String = ""
	if y_labels.empty():
		tick_lbl = ("%.2f" if y_has_decimals else "%s") % [y_domain.left + (line_index * line_value)]
	else:
		tick_lbl = y_labels[clamp(y_labels.size() * line_index, 0, y_labels.size() - 1)]
	
	draw_string(
		chart_properties.font, 
		position - Vector2(
			chart_properties.font.get_string_size(tick_lbl).x + _y_ticklabel_offset + _y_tick_size, 
			- _y_ticklabel_size.y * 0.35
		), 
		tick_lbl, 
		chart_properties.colors.bounding_box
	)


func _draw_horizontal_gridline_component(p1: Vector2, p2: Vector2, line_index: int, line_value: float) -> void:
	# Draw H labels
	if chart_properties.labels:
		_draw_horizontal_tick_label(
			chart_properties.font, 
			p1,
			chart_properties.colors.bounding_box,
			line_index,
			line_value 
		)
	
	# Draw H Ticks
	if chart_properties.ticks:
		_draw_tick(p1, p1 - Vector2(_y_tick_size, 0), chart_properties.colors.bounding_box)
	
	# Draw H Grid Lines
	if chart_properties.grid:
		draw_line(p1, p2, chart_properties.colors.grid, 1, true)

func _draw_vertical_grid() -> void:
	# draw vertical lines
	
	# 1. the amount of lines is equals to the X_scale: it identifies in how many sectors the x domain
	#    should be devided
	# 2. calculate the spacing between each line in pixel. It is equals to x_sampled_domain / x_scale
	# 3. calculate the offset in the real x domain, which is x_domain / x_scale.
	var x_pixel_dist: float = (x_sampled.min_max.right - x_sampled.min_max.left) / (chart_properties.x_scale)
	var x_lbl_val: float = (x_min_max.right - x_min_max.left) / (chart_properties.x_scale)
	for _x in chart_properties.x_scale + 1:
		var x_val: float = _x * x_pixel_dist + x_sampled.min_max.left
		var top: Vector2 = Vector2(
			range_lerp(x_val, x_sampled.min_max.left, x_sampled.min_max.right, x_sampled_domain.left, x_sampled_domain.right),
			bounding_box.position.y
		)
		var bottom: Vector2 = Vector2(
			range_lerp(x_val, x_sampled.min_max.left, x_sampled.min_max.right, x_sampled_domain.left, x_sampled_domain.right),
			bounding_box.size.y + bounding_box.position.y
		)
		
		_draw_vertical_gridline_component(top, bottom, _x, x_lbl_val)

func _draw_horizontal_grid() -> void:
	# 1. the amount of lines is equals to the y_scale: it identifies in how many sectors the y domain
	#    should be devided
	# 2. calculate the spacing between each line in pixel. It is equals to y_sampled_domain / y_scale
	# 3. calculate the offset in the real y domain, which is y_domain / y_scale.
	var y_pixel_dist: float = (y_sampled.min_max.right - y_sampled.min_max.left) / (chart_properties.y_scale)
	var y_lbl_val: float = (y_domain.right - y_domain.left) / (chart_properties.y_scale)
	for _y in chart_properties.y_scale + 1:
		var y_val: float = (_y * y_pixel_dist) + y_sampled.min_max.left
		var left: Vector2 = Vector2(
			bounding_box.position.x,
			range_lerp(y_val, y_sampled.min_max.left, y_sampled.min_max.right, y_sampled_domain.left, y_sampled_domain.right)
		)
		var right: Vector2 = Vector2(
			bounding_box.size.x + bounding_box.position.x,
			range_lerp(y_val, y_sampled.min_max.left, y_sampled.min_max.right, y_sampled_domain.left, y_sampled_domain.right)
		)
		
		_draw_horizontal_gridline_component(left, right, _y, y_lbl_val)

func _draw_grid() -> void:
	var validation: int = _validate_sampled_axis(x_sampled, y_sampled)
	if not validation == OK:
		printerr("Cannot draw grid for invalid dataset! Error: %s" % validation)
		return
	
	_draw_vertical_grid()
	_draw_horizontal_grid()

func _create_canvas_label(text: String, position: Vector2, rotation: float = 0.0) -> Label:
	var lbl: Label = Label.new()
	$Canvas.add_child(lbl)
	lbl.set("custom_fonts/font", chart_properties.font)
	lbl.set_text(text)
	lbl.modulate = chart_properties.colors.bounding_box
	lbl.rect_rotation = rotation
	lbl.rect_position = position
	return lbl

func _update_canvas_label(canvas_label: Label, text: String, position: Vector2, rotation: float = 0.0) -> void:
	canvas_label.set_text(text)
	canvas_label.modulate = chart_properties.colors.bounding_box
	canvas_label.rect_rotation = rotation
	canvas_label.rect_position = position

func _draw_yaxis_label() -> void:
	_update_canvas_label(
		$Canvas/YLabel,
		chart_properties.y_label,
		Vector2(_padding_offset.x, (node_box.size.y / 2) + (_y_label_size.x / 2)),
		-90
	)

func _draw_xaxis_label() -> void:
	_update_canvas_label(
		$Canvas/XLabel,
		chart_properties.x_label,
		Vector2(
			node_box.size.x/2 - (_x_label_size.x / 2), 
			node_box.size.y - _padding_offset.y - _x_label_size.y 
		)
	)

func _draw_title() -> void:
	_update_canvas_label(
		$Canvas/Title,
		chart_properties.title,
		Vector2(node_box.size.x / 2, _padding_offset.y*2) - (chart_properties.font.get_string_size(chart_properties.title) / 2)
	)

func _clear_canvas_labels() -> void:
	for label in $Canvas.get_children():
		label.queue_free()

func _clear() -> void:
	_clear_canvas_labels()

# Draw Loop:
#    the drow loop gives order to what thigs will be drawn
#    each chart specifies its own draw loop that inherits from this one.
#    The draw loop also contains the "processing loop" which is where
#    everything is calculated in a separated function.
func _draw():
	if not (validate_input_samples(x) and validate_input_samples(y)):
		printerr("Input samples are invalid!")
		return 
	
	_clear()
	_pre_process()
	
	if chart_properties.background:
		_draw_background()
	
	if chart_properties.borders:
		_draw_borders()
	
	if chart_properties.grid or chart_properties.ticks or chart_properties.labels:
		_draw_grid()
	
	if chart_properties.bounding_box:
		_draw_bounding_box()
	
	if chart_properties.origin:
		_draw_origin()
	
	if chart_properties.labels:
		_draw_xaxis_label()
		_draw_yaxis_label()
		_draw_title()

func _validate_sampled_axis(x_data: SampledAxis, y_data: SampledAxis) -> int:
	var error: int = 0 # OK
	if x_data.values.empty() or y_data.values.empty():
		# Either there are no X or Y
		error = 1
	elif y_data.values[0] is Array:
		for dim in y_data.values:
			if dim.size() != x_data.values.size():
				error = 3 # one of Y dim has not X length
				break
	else:
		if y_data.values.size() != x_data.values.size():
			# X and Y samples don't have same length
			error = 2
	return error

# ----- utilities
func _get_function_name(function_idx: int) -> String:
	return functions_names[function_idx] if functions_names.size() > 0 else "Function %s" % function_idx

func _get_function_color(function_idx: int) -> Color:
	return chart_properties.colors.functions[function_idx] if chart_properties.colors.functions.size() > 0 else Color.black
