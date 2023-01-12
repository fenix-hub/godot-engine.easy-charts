extends Control
class_name Chart

var x: Array
var y: Array

var x_min_max: Pair = Pair.new()
var y_min_max: Pair = Pair.new()

var x_sampled: SampledAxis = SampledAxis.new()
var y_sampled: SampledAxis = SampledAxis.new()

var x_labels: Array = []
var y_labels: Array = []

###### STYLE
var chart_properties: ChartProperties = ChartProperties.new()

#### INTERNAL
# The bounding_box of the chart
var node_box: Rect2
var bounding_box: Rect2

# The Reference Rectangle to plot samples
# It is the @bounding_box Rectangle inverted on the Y axis
var x_sampled_domain: Pair
var y_sampled_domain: Pair
var sampled_domain_rect: Rect2

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
func plot(x: Array, y: Array, properties: ChartProperties = self.chart_properties) -> void:
	pass

func _map_pair(val: float, rel: Pair, ref: Pair) -> float:
	return range_lerp(val, rel.left, rel.right, ref.left, ref.right)

func _has_decimals(values: Array) -> bool:
	var temp: Array = values.duplicate(true)
	
	if temp[0] is Array:
		for dim in temp:
			for val in dim:
				if abs(fmod(val, 1)) > 0.0:
					 return true
	else:
		for val in temp:
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
	var _min: float
	var _max: float
	
	var rels: Array = []
	if temp[0] is Array:
		for t_dim in temp:
			var rels_t: Array = []
			for val in t_dim:
				rels_t.append(_map_pair(val, rel_values, ref_values))
			rels.append(rels_t)
		
	else:
		for val in temp:
			rels.append(_map_pair(val, rel_values, ref_values))
	
	return SampledAxis.new(rels, rel_values)


func _pre_process_drawings() -> void:
	var t_gr: Rect2 = get_global_rect()
	
	#### @node_box size, which is the whole "frame"
	node_box = Rect2(Vector2.ZERO, t_gr.size - t_gr.position)
	
	#### drawing size for defining @bounding_box
	x_min_max = _find_min_max(x)
	y_min_max = _find_min_max(y)
	
	#### calculating offset from the @node_box for the @bounding_box.
	var offset: Vector2 = _padding_offset
	
	### if @labels drawing is enabled, calcualte offsets
	if chart_properties.labels:
		### labels (X, Y, Title)
		_x_label_size = chart_properties.font.get_string_size(chart_properties.x_label)
		_y_label_size = chart_properties.font.get_string_size(chart_properties.y_label)
		
		### tick labels
		
		###### --- X
		x_has_decimals = _has_decimals(x)
		# calculate the string length of the largest value on the Y axis.
		# remember that "-" sign adds additional pixels, and it is relative only to negative numbers!
		var x_max_formatted: String = ("%.2f" if x_has_decimals else "%s") % x_min_max.right
		_x_ticklabel_size = chart_properties.font.get_string_size(x_max_formatted)
		
		offset.y += _x_label_offset + _x_label_size.y + _x_ticklabel_offset + _x_ticklabel_size.y
		
		###### --- Y
		y_has_decimals = _has_decimals(y)
		# calculate the string length of the largest value on the Y axis.
		# remember that "-" sign adds additional pixels, and it is relative only to negative numbers!
		var y_max_formatted: String = ("%.2f" if y_has_decimals else "%s") % y_min_max.right
		if y_min_max.left < 0:
			# negative number
			var y_min_formatted: String = ("%.2f" if y_has_decimals else "%s") % y_min_max.left
			if y_min_formatted.length() >= y_max_formatted.length():
				 _y_ticklabel_size = chart_properties.font.get_string_size(y_min_formatted)
			else:
				_y_ticklabel_size = chart_properties.font.get_string_size(y_max_formatted)
		else:
			_y_ticklabel_size = chart_properties.font.get_string_size(y_max_formatted)
		
		offset.x += _y_label_offset + _y_label_size.y + _y_ticklabel_offset + _y_ticklabel_size.x
	
	### if @ticks drawing is enabled, calculate offsets
	if chart_properties.ticks:
		offset.x += _y_tick_size
		offset.y += _x_tick_size
	
	### @bounding_box, where the points will be plotted
	bounding_box = Rect2(
		offset, 
		t_gr.size - (offset * 2)
	)
	
	### @sampled_domain, which are the domain relative to the sampled values
	### x (real value) --> sampling --> x_sampled (pixel value in canvas)
	x_sampled_domain = Pair.new(bounding_box.position.x + _internal_offset.x, bounding_box.position.x + bounding_box.size.x - _internal_offset.y)
	y_sampled_domain = Pair.new(bounding_box.size.y + bounding_box.position.y - _internal_offset.x, bounding_box.position.y + _internal_offset.y)
	sampled_domain_rect = Rect2(
		Vector2(x_sampled_domain.left, y_sampled_domain.left),
		Vector2(x_sampled_domain.right, y_sampled_domain.right)
	)

func _pre_process_sampling() -> void:
	
	# samples
	x_sampled = _sample_values(x, x_min_max, x_sampled_domain)
	y_sampled = _sample_values(y, y_min_max, y_sampled_domain)

func _pre_process() -> void:
	_pre_process_drawings()
	_pre_process_sampling()



func _draw_points() -> void:
	pass

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
	var yorigin: float = _map_pair(0.0, y_min_max, y_sampled_domain)
	draw_line(Vector2(xorigin, bounding_box.position.y), Vector2(xorigin, bounding_box.position.y + bounding_box.size.y), Color.black, 1, 0)
	draw_line(Vector2(bounding_box.position.x, yorigin), Vector2(bounding_box.position.x + bounding_box.size.x, yorigin), Color.black, 1, 0)
	draw_string(chart_properties.font, Vector2(xorigin, yorigin) - Vector2(15, -15), "O", chart_properties.colors.bounding_box)

func _draw_background() -> void:
	draw_rect(node_box, Color.white, true, 1.0, false)
	
#	# (debug)
#	var half: Vector2 = node_box.size / 2
#	draw_line(Vector2(half.x, node_box.position.y), Vector2(half.x, node_box.size.y), Color.red, 3, false)
#	draw_line(Vector2(node_box.position.x, half.y), Vector2(node_box.size.x, half.y), Color.red, 3, false)

func _draw_grid() -> void:
	var validation: int = _validate_sampled_axis(x_sampled, y_sampled)
	if not validation == OK:
		printerr("Cannot draw grid for invalid dataset! Error: %s" % validation)
		return
	
	# draw vertical lines
	var v_lines: float = (x_sampled.min_max.right - x_sampled.min_max.left) / (chart_properties.x_scale - 1)
	var x_labels_spacing: float = x_labels.size() / (chart_properties.x_scale - 1)
	for _x in chart_properties.x_scale:
		var x_val: float = _x * v_lines + x_sampled.min_max.left
		var p1: Vector2 = Vector2(
			range_lerp(x_val, x_sampled.min_max.left, x_sampled.min_max.right, x_sampled_domain.left, x_sampled_domain.right),
			bounding_box.position.y
		)
		var p2: Vector2 = Vector2(
			range_lerp(x_val, x_sampled.min_max.left, x_sampled.min_max.right, x_sampled_domain.left, x_sampled_domain.right),
			bounding_box.size.y + bounding_box.position.y
		)
		
		# Draw V labels
		if chart_properties.labels:
			var tick_lbl: String = ""
			if x_labels.empty():
				tick_lbl = ("%.2f" if x_has_decimals else "%s") % x_val
			else:
				tick_lbl = x_labels[clamp(x_labels_spacing * _x, 0, x_labels.size() - 1)]
			
			draw_string(
				chart_properties.font, 
				p2 + Vector2(
					- chart_properties.font.get_string_size(tick_lbl).x / 2,
					_x_label_size.y + _x_tick_size
				), 
				tick_lbl, 
				chart_properties.colors.bounding_box
			)
		
		# Draw V Ticks
		if chart_properties.ticks:
			draw_line(p2, p2 + Vector2(0, _x_tick_size), chart_properties.colors.bounding_box, 1, true)
		
		# Draw V Grid Lines
		if chart_properties.grid:
			draw_line(p1, p2, chart_properties.colors.grid, 1, true)
	
	# draw horizontal lines
	var h_lines: float = (y_sampled.min_max.right - y_sampled.min_max.left) / (chart_properties.y_scale - 1)
	var y_labels_spacing: float = y_labels.size() / (chart_properties.y_scale - 1)
	for _y in chart_properties.y_scale:
		var y_val: float = _y * h_lines + y_sampled.min_max.left
		var p1: Vector2 = Vector2(
			bounding_box.position.x,
			range_lerp(y_val, y_sampled.min_max.left, y_sampled.min_max.right, y_sampled_domain.left, y_sampled_domain.right)
		)
		var p2: Vector2 = Vector2(
			bounding_box.size.x + bounding_box.position.x,
			range_lerp(y_val, y_sampled.min_max.left, y_sampled.min_max.right, y_sampled_domain.left, y_sampled_domain.right)
		)
		
		# Draw H labels
		if chart_properties.labels:
			var tick_lbl: String = ""
			if y_labels.empty():
				tick_lbl = ("%.2f" if y_has_decimals else "%s") % y_val
			else:
				tick_lbl = y_labels[clamp(y_labels * _y, 0, y_labels.size() - 1)]
			
			draw_string(
				chart_properties.font, 
				p1 - Vector2(chart_properties.font.get_string_size(tick_lbl).x + _y_ticklabel_offset + _y_tick_size, - _y_ticklabel_size.y * 0.35),
				tick_lbl, 
				chart_properties.colors.bounding_box
			)
		
		# Draw H Ticks
		if chart_properties.ticks:
			draw_line(
				p1, 
				p1 - Vector2(_y_tick_size, 0), 
				chart_properties.colors.bounding_box, 1, true)
		
		# Draw H Grid Lines
		if chart_properties.grid:
			draw_line(p1, p2, chart_properties.colors.grid, 1, true)

func _create_canvas_label(text: String, position: Vector2, rotation: float = 0.0) -> Label:
	var lbl: Label = Label.new()
	$Canvas.add_child(lbl)
	lbl.set("custom_fonts/font", chart_properties.font)
	lbl.set_text(text)
	lbl.modulate = chart_properties.colors.bounding_box
	lbl.rect_rotation = rotation
	lbl.rect_position = position
	return lbl

func _draw_yaxis_label() -> void:
	_create_canvas_label(
		chart_properties.y_label,
		Vector2(_padding_offset.x, (node_box.size.y / 2) + (_y_label_size.x / 2)),
		-90
	)

func _draw_xaxis_label() -> void:
	_create_canvas_label(
		chart_properties.x_label,
		Vector2(
			node_box.size.x/2 - (_x_label_size.x / 2), 
			node_box.size.y - _padding_offset.y - _x_label_size.y 
		)
	)

func _draw_title() -> void:
	_create_canvas_label(
		chart_properties.title,
		Vector2(node_box.size.x / 2, _padding_offset.y*2) - (chart_properties.font.get_string_size(chart_properties.title) / 2)
	)

func _clear_points() -> void:
	pass
#	for point in $Points.get_children():
#		point.queue_free()

func _clear_canvas_labels() -> void:
	for label in $Canvas.get_children():
		label.queue_free()

func _clear() -> void:
	_clear_points()
	_clear_canvas_labels()

func _draw():
	_clear()
	_pre_process()
	
	if chart_properties.background:
		_draw_background()
	
	if chart_properties.borders:
		_draw_borders()
	
	if chart_properties.labels:
		_draw_xaxis_label()
		_draw_yaxis_label()
		_draw_title()
	
	if chart_properties.grid or chart_properties.ticks or chart_properties.labels:
		_draw_grid()
	
	if chart_properties.bounding_box:
		_draw_bounding_box()
	
	if chart_properties.origin:
		_draw_origin()
	
	if chart_properties.points:
		_draw_points()

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
