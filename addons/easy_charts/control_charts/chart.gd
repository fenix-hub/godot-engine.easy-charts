extends AbstractChart
class_name Chart

var x: Array
var y: Array

var x_min_max: Pair = Pair.new() # Min and Max values of @x
var x_domain: Pair = Pair.new()  # Rounded domain of values of @x
var y_min_max: Pair = Pair.new() # Min and Max values of @y
var y_domain: Pair = Pair.new()  # Rounded domain of values of @x

var x_sampled: SampledAxis = SampledAxis.new()
var y_sampled: SampledAxis = SampledAxis.new()

# The Reference Rectangle to plot samples
# It is the @bounding_box Rectangle inverted on the Y axis
var x_sampled_domain: Pair
var y_sampled_domain: Pair


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
func plot(x: Array, y: Array, properties: ChartProperties = self.chart_properties) -> void:
	self.x = x
	self.y = y
	
	if properties != null:
		self.chart_properties = properties
	
	set_process_input(chart_properties.interactive)
	
	update()


# Draw Loop:
#    the drow loop gives order to what thigs will be drawn
#    each chart specifies its own draw loop that inherits from this one.
#    The draw loop also contains the "processing loop" which is where
#    everything is calculated in a separated function.
func _draw():
	if not (validate_input_samples(x) and validate_input_samples(y)):
		printerr("Input samples are invalid!")
		return 
	
	if chart_properties.origin:
		_draw_origin()

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
				rels_t.append(rel_values.map(val, ref_values))
			rels.append(rels_t)
		
	else:
		division_size = (ref_values.right - ref_values.left) / values.size()
		for val_i in temp.size():
			if temp[val_i] is String:
				rels.append(val_i * division_size)
			else:
				rels.append(rel_values.map(temp[val_i], ref_values))
	
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

func _calc_bounding_box() -> void:
	_calc_x_domain()
	_calc_y_domain()
	
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

func _post_process() -> void:
	_sample_x()
	_sample_y()

func _draw_origin() -> void:
	var xorigin: float = x_min_max.map(0.0, x_sampled_domain)
	var yorigin: float = y_domain.map(0.0, y_sampled_domain)
	
	draw_line(Vector2(xorigin, bounding_box.position.y), Vector2(xorigin, bounding_box.position.y + bounding_box.size.y), Color.black, 1, 0)
	draw_line(Vector2(bounding_box.position.x, yorigin), Vector2(bounding_box.position.x + bounding_box.size.x, yorigin), Color.black, 1, 0)
	draw_string(chart_properties.font, Vector2(xorigin, yorigin) - Vector2(15, -15), "O", chart_properties.colors.bounding_box)

func _draw_grid() -> void:
	var validation: int = _validate_sampled_axis(x_sampled, y_sampled)
	if not validation == OK:
		printerr("Cannot draw grid for invalid dataset! Error: %s" % validation)
		return
	
	_draw_vertical_grid()
	_draw_horizontal_grid()

func _draw_vertical_grid() -> void:
	# draw vertical lines
	
	# 1. the amount of lines is equals to the X_scale: it identifies in how many sectors the x domain
	#    should be devided
	# 2. calculate the spacing between each line in pixel. It is equals to x_sampled_domain / x_scale
	# 3. calculate the offset in the real x domain, which is x_domain / x_scale.
	var x_pixel_dist: float = (x_sampled.min_max.right - x_sampled.min_max.left) / (chart_properties.x_scale)
	var x_lbl_val: float = (x_min_max.right - x_min_max.left) / (chart_properties.x_scale)
	
	var vertical_grid: PoolVector2Array = []
	var vertical_ticks: PoolVector2Array = []
	
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
		
		vertical_grid.append(top)
		vertical_grid.append(bottom)
		
		vertical_ticks.append(bottom)
		vertical_ticks.append(bottom + Vector2(0, _x_tick_size))
		
		# Draw V Tick Labels
		if chart_properties.labels:
			var tick_lbl: String = _get_vertical_tick_label(_x, x_val)
			draw_string(
				chart_properties.font, 
				_get_vertical_tick_label_pos(bottom, tick_lbl),
				tick_lbl, 
				chart_properties.colors.bounding_box
			)
	
	# Draw V Grid
	if chart_properties.grid:
		draw_multiline(vertical_grid, chart_properties.colors.grid, 1, true)
	
	# Draw V Ticks
	if chart_properties.ticks:
		draw_multiline(vertical_ticks, chart_properties.colors.bounding_box, 1, true)


func _draw_horizontal_grid() -> void:
	# 1. the amount of lines is equals to the y_scale: it identifies in how many sectors the y domain
	#    should be devided
	# 2. calculate the spacing between each line in pixel. It is equals to y_sampled_domain / y_scale
	# 3. calculate the offset in the real y domain, which is y_domain / y_scale.
	var y_pixel_dist: float = (y_sampled.min_max.right - y_sampled.min_max.left) / (chart_properties.y_scale)
	var y_lbl_val: float = (y_domain.right - y_domain.left) / (chart_properties.y_scale)
	
	var horizontal_grid: PoolVector2Array = []
	var horizontal_ticks: PoolVector2Array = []
	
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
		
		horizontal_grid.append(left)
		horizontal_grid.append(right)
		
		horizontal_ticks.append(left)
		horizontal_ticks.append(left - Vector2(_y_tick_size, 0))
		
		# Draw H Tick Labels
		if chart_properties.labels:
			var tick_lbl: String = _get_horizontal_tick_label(_y, y_val)
			draw_string(
				chart_properties.font, 
				_get_horizontal_tick_label_pos(left, tick_lbl),
				tick_lbl, 
				chart_properties.colors.bounding_box
			)
	
	# Draw H Grid
	if chart_properties.grid:
		draw_multiline(horizontal_grid, chart_properties.colors.grid, 1, true)
	
	# Draw H Ticks
	if chart_properties.ticks:
		draw_multiline(horizontal_ticks, chart_properties.colors.bounding_box, 1, true)
		

func _get_vertical_tick_label_pos(base_position: Vector2, text: String) -> Vector2:
	return  base_position + Vector2(
		- chart_properties.font.get_string_size(text).x / 2,
		_x_label_size.y + _x_tick_size
	)

func _get_horizontal_tick_label_pos(base_position: Vector2, text: String) -> Vector2:
	return base_position - Vector2(
		chart_properties.font.get_string_size(text).x + _y_ticklabel_offset + _y_tick_size, 
		- _y_ticklabel_size.y * 0.35
	)

func _get_vertical_tick_label(line_index: int, line_value: float) -> String:
	var tick_lbl: String = ""
	if x_labels.empty():
		tick_lbl = ("%.2f" if x_has_decimals else "%s") % line_value
	else:
		tick_lbl = x_labels[line_index]
  
	return tick_lbl

func _get_horizontal_tick_label(line_index: int, line_value: float) -> String:
	var tick_lbl: String = ""
	if y_labels.empty():
		tick_lbl = ("%.2f" if y_has_decimals else "%s") % line_value
	else:
		tick_lbl = y_labels[line_index]
	
	return tick_lbl

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
func validate_input_samples(samples: Array) -> bool:
	if samples.size() > 1 and samples[0] is Array:
		for sample in samples:
			if (not sample is Array) or sample.size() != samples[0].size():
				return false
	return true
