extends Control
class_name Chart

var x: Array
var y: Array

var x_sampled: SampledAxis
var y_sampled: SampledAxis

# 
var x_scale: float = 5.0
var y_scale: float = 5.0


###### STYLE
var drawing_options: DrawingOptions = DrawingOptions.new()


#### INTERNAL
# The bounding_box of the chart
var node_box: Rect2
var bounding_box: Rect2

# The Reference Rectangle to plot samples
# It is the @bounding_box Rectangle inverted on the Y axis
var ref_x: Pair
var ref_y: Pair
var ref_rect: Rect2

var _padding_offset: Vector2 = Vector2(70.0, 70.0)
var _internal_offset: Vector2 = Vector2(15.0, 15.0)

var point_container_scene: PackedScene = preload("res://addons/easy_charts/utilities/containers/point_container/point_container.tscn")


###########
func plot(x: Array, y: Array) -> void:
	pass

func _sample_values(values: Array, ref_values: Pair) -> SampledAxis:
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
		var min_ts: Array
		var max_ts: Array
		for dim in temp:
			min_ts.append(dim.min())
			max_ts.append(dim.max())
		_min = min_ts.min()
		_max = max_ts.max()
		
		for t_dim in temp:
			var rels_t: Array = []
			for val in t_dim:
				rels_t.append(range_lerp(val, _min, _max, ref_values.left, ref_values.right))
			rels.append(rels_t)
		
	else:
		_min = temp.min()
		_max = temp.max()
		
		for val in temp:
			rels.append(range_lerp(val, _min, _max, ref_values.left, ref_values.right))
	
	return SampledAxis.new(rels, Pair.new(_min, _max))

func _pre_process() -> void:
	var t_gr: Rect2 = get_global_rect()
	
	# node box
	node_box = Rect2(Vector2.ZERO, t_gr.size - t_gr.position)
	
	# bounding_box
	bounding_box = Rect2(
		Vector2.ZERO + _padding_offset, 
		t_gr.size - t_gr.position - (_padding_offset*2) 
	)
	
	# reference rectangle
	ref_x = Pair.new(bounding_box.position.x + _internal_offset.x, bounding_box.position.x + bounding_box.size.x - _internal_offset.y)
	ref_y = Pair.new(bounding_box.size.y + bounding_box.position.y - _internal_offset.x, bounding_box.position.y + _internal_offset.y)
	ref_rect = Rect2(
		Vector2(ref_x.left, ref_y.left),
		Vector2(ref_x.right, ref_y.right)
	)
	
	# samples
	x_sampled = _sample_values(x, ref_x)
	y_sampled = _sample_values(y, ref_y)

func _draw_borders() -> void:
	draw_rect(node_box, Color.red, false, 1, true)

func _draw_bounding_box() -> void:
	draw_rect(bounding_box, drawing_options.colors.bounding_box, false, 1, true)


func _draw_points() -> void:
	pass

func _draw_background() -> void:
	draw_rect(node_box, Color.white, true, 1.0, true)

func _draw_grid() -> void:
	var validation: int = _validate_sampled_axis(x_sampled, y_sampled)
	if not validation == OK:
		printerr("Cannot draw grid for invalid dataset! Error: %s" % validation)
		return
	
	# draw vertical lines
	var v_lines: float = (x_sampled.min_max.right - x_sampled.min_max.left) / x_scale
	for _x in x_scale+1:
		var x_val: float = _x * v_lines + x_sampled.min_max.left
		var p1: Vector2 = Vector2(
			range_lerp(x_val, x_sampled.min_max.left, x_sampled.min_max.right, ref_x.left, ref_x.right),
			bounding_box.position.y
		)
		var p2: Vector2 = Vector2(
			range_lerp(x_val, x_sampled.min_max.left, x_sampled.min_max.right, ref_x.left, ref_x.right),
			bounding_box.size.y + bounding_box.position.y
		)
		
		# Draw V Grid Lines
		if drawing_options.grid:
			draw_line(p1, p2, drawing_options.colors.grid, 1, true)
		
		# Draw V Ticks
		if drawing_options.ticks:
			p1.y = p2.y
			p2.y += 8.0
			draw_line(p1, p2, drawing_options.colors.bounding_box, 1, true)
		
		# Draw V labels
		if drawing_options.labels:
			draw_string(
				drawing_options.font, 
				p2 + Vector2(-drawing_options.font.get_string_size(str(x_val)).x * 0.5, 15.0), 
				str(x_val), 
				drawing_options.colors.bounding_box
			)

	# draw horizontal lines
	var h_lines: float = (y_sampled.min_max.right - y_sampled.min_max.left) / y_scale
	for _y in y_scale+1:
		var y_val: float = _y * h_lines + y_sampled.min_max.left
		var p1: Vector2 = Vector2(
			bounding_box.position.x,
			range_lerp(y_val, y_sampled.min_max.left, y_sampled.min_max.right, ref_y.left, ref_y.right)
		)
		var p2: Vector2 = Vector2(
			bounding_box.size.x + bounding_box.position.x,
			range_lerp(y_val, y_sampled.min_max.left, y_sampled.min_max.right, ref_y.left, ref_y.right)
		)
		
		# Draw H Grid Lines
		if drawing_options.grid:
			draw_line(p1, p2, drawing_options.colors.grid, 1, true)
		
		# Draw H Ticks
		if drawing_options.ticks:
			p2.x = p1.x - 8.0
			draw_line(p1, p2, drawing_options.colors.bounding_box, 1, true)
			
		# Draw H labels
		if drawing_options.labels:
			draw_string(
				drawing_options.font, 
				p2 - Vector2(drawing_options.font.get_string_size(str(y_val)).x + 5.0, -drawing_options.font.get_string_size(str(y_val)).y * 0.35), 
				str(y_val), 
				drawing_options.colors.bounding_box
			)


func _clear_points() -> void:
	for point in $Points.get_children():
		point.queue_free()

func _clear() -> void:
	_clear_points()

func _draw():
	if drawing_options.background:
		_draw_background()
	
	if drawing_options.borders:
		_draw_borders()
	
	if drawing_options.grid or drawing_options.ticks or drawing_options.labels:
		_draw_grid()
		
	if drawing_options.bounding_box:
		_draw_bounding_box()
	
	if drawing_options.points:
		_draw_points()
	
#	if drawing_options.labels:
#		_draw_labels()

func _validate_sampled_axis(x_data: SampledAxis, y_data: SampledAxis) -> int:
	var error: int = 0 # OK
	if x_data.values.empty() or y_data.values.empty():
		# Either there are no X or Y
		error = 1
	if y_data.values[0] is Array:
		for dim in y_data.values:
			if dim.size() != x_data.values.size():
				error = 3 # one of Y dim has not X length
				break
	else:
		if y_data.values.size() != x_data.values.size():
			# X and Y samples don't have same length
			error = 2
	return error
