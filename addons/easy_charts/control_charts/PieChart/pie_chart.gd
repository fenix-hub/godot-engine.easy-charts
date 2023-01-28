extends AbstractChart
class_name PieChart

signal slice_entered(slice)

var values: Array = []

var radius_multiplayer: float = 1.0

#### INTERNAL
var ratios: Array = []
var total: float = 0.0

var _slices_polygons: Array = []
var _slices_dirs: Array = []

var _radius: float

var focused_slice: PoolVector2Array

func _ready() -> void:
	set_process_input(false)
	set_process(false)

func plot(values: Array, properties: ChartProperties = self.chart_properties) -> void:
	self.values = values
	
	if properties != null:
		self.chart_properties = properties
		self.chart_properties.bounding_box = false
	
	set_process_input(chart_properties.interactive)

func _draw() -> void:
	_calc_slices()
	_draw_pie()

func _calc_slices() -> void:
	_radius = min(plot_box.size.x, plot_box.size.y) * 0.5 * radius_multiplayer
	# Calculate total and ratios
	var total: float = 0.0
	for value in values:
		total += float(value)
	
	ratios.clear()
	for value in values:
		ratios.append(value / total * 100)
	
	# Calculate directions
	_slices_polygons.clear()
	_slices_dirs.clear()
	var center: Vector2 = plot_box.get_center()
	var start_angle: float = 0.0
	for i in ratios.size():
		var end_angle: float = start_angle + (2 * PI * float(ratios[i]) * 0.01)
		_slices_polygons.append(
			_calc_circle_arc_poly(
				plot_box.get_center(),
				_radius,
				start_angle,
				end_angle
			)
		)
		var mid_point: Vector2 = ((center + (Vector2.RIGHT.rotated(start_angle).normalized() * _radius)) + (center + (Vector2.RIGHT.rotated(end_angle).normalized() * _radius))) / 2
		_slices_dirs.append(center.direction_to(mid_point) * (-1 if (end_angle - start_angle) > PI else 1))
		start_angle = end_angle

func _calc_circle_arc_poly(center: Vector2, radius: float, angle_from: float, angle_to: float) -> PoolVector2Array:
	var nb_points: int = 64
	var points_arc: PoolVector2Array = PoolVector2Array()
	points_arc.push_back(center)
	
	for i in range(nb_points + 1):
		var angle_point: float = - (PI / 2) + angle_from + i * (angle_to - angle_from) / nb_points
		points_arc.push_back(center + (Vector2.RIGHT.rotated(angle_point).normalized() * radius))
	
	return points_arc

func _draw_pie() -> void:
	for i in _slices_polygons.size():
		draw_polygon(_slices_polygons[i], [chart_properties.get_function_color(i)])
		draw_polyline(_slices_polygons[i] + PoolVector2Array([_slices_polygons[i][0]]), Color.white, 2.0, true)

func _draw_labels() -> void:
	for i in _slices_dirs.size():
		var ratio_lbl: String = "%.1f%%" % ratios[i]
		var value_lbl: String = "(%s)" % values[i]
		var position: Vector2 = plot_box.get_center() + _slices_dirs[i] * _radius * 0.5
		var ratio_lbl_size: Vector2 = chart_properties.get_string_size(ratio_lbl)
		var value_lbl_size: Vector2 = chart_properties.get_string_size(value_lbl)
		draw_string(
			chart_properties.font,
			position - Vector2(ratio_lbl_size.x / 2, 0),
			ratio_lbl,
			Color.white
		)
		draw_string(
			chart_properties.font,
			position - Vector2(value_lbl_size.x / 2, - value_lbl_size.y),
			value_lbl,
			Color.white
		)

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		for slice_i in _slices_polygons.size():
			var slice: PoolVector2Array = _slices_polygons[slice_i]
			if Geometry.is_point_in_polygon(event.position, slice):
				if focused_slice == slice:
					return
				else:
					focused_slice = slice
					$Tooltip.update_values(
						"%.1f%%" % ratios[slice_i],
						"%s" % values[slice_i],
						chart_properties.get_function_name(slice_i),
						chart_properties.get_function_color(slice_i)
					)
					$Tooltip.show()
					emit_signal("slice_entered", slice)
					return
		# Mouse is not in any slice's box
		focused_slice = PoolVector2Array()
		$Tooltip.hide()
