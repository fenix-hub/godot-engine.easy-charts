extends Chart
class_name ScatterChart

signal point_entered(point)

var focused_point: Point = null

var points: Array = []
var _point_box_rad: int = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func plot(x: Array, y: Array, properties: ChartProperties = self.chart_properties) -> void:
	self.x = x
	self.y = y
	
	if properties != null:
		self.chart_properties = properties
	
	update()

func _clear_points() -> void:
	points = []

func _get_point_box(point: Point, rad: int) -> Rect2:
	return Rect2(point.position - (Vector2.ONE * rad), (Vector2.ONE * rad * 2))

func _move_tooltip(position: Vector2) -> void:
	$Label.set_position(position + (Vector2.ONE * 15))

func _show_tooltip(position: Vector2, text: String) -> void:
	_move_tooltip(position)
	$Label.show()
	$Label.set_text(text)
	$Label.set_size(Vector2.ZERO)

func _hide_tooltip() -> void:
	$Label.hide()
	$Label.set_text("")
	$Label.set_size(Vector2.ZERO)

func _input(event: InputEvent):
	if event is InputEventMouse:
		for point in points:
			if _get_point_box(point, _point_box_rad).abs().has_point(event.position):
				if focused_point == point:
					_move_tooltip(event.position)
					return
				else:
					focused_point = point
					_show_tooltip(event.position, str(focused_point.value))
					emit_signal("point_entered", point)
					return
		# Mouse is not in any point's box
		focused_point = null
		_hide_tooltip()

func _draw_point(point: Point, function_index: int) -> void:
	points.append(point)
	
	match chart_properties.get_point_shape(function_index):
		Point.Shape.CIRCLE:
			draw_circle(point.position, chart_properties.point_radius,  chart_properties.get_function_color(function_index))
		Point.Shape.SQUARE:
			draw_rect(_get_point_box(point, chart_properties.point_radius), chart_properties.get_function_color(function_index), true, 1.0, false)
		Point.Shape.TRIANGLE:
			draw_colored_polygon(
				PoolVector2Array([
					point.position + (Vector2.UP * chart_properties.point_radius * 1.3),
					point.position + (Vector2.ONE * chart_properties.point_radius * 1.3),
					point.position - (Vector2(1, -1) * chart_properties.point_radius * 1.3)
				]), chart_properties.get_function_color(function_index), [], null, null, false
			)
		Point.Shape.CROSS:
			draw_line(
				point.position - (Vector2.ONE * chart_properties.point_radius),
				point.position + (Vector2.ONE * chart_properties.point_radius),
				chart_properties.get_function_color(function_index), chart_properties.point_radius, true
			)
			draw_line(
				point.position + (Vector2(1, -1) * chart_properties.point_radius),
				point.position + (Vector2(-1, 1) * chart_properties.point_radius),
				chart_properties.get_function_color(function_index), chart_properties.point_radius / 2, true
			)
	
#	# (debug)
#	draw_rect(
#		_get_point_box(point, _point_box_rad),
#		Color.red,
#		false, 1, true
#	)

func _draw_points() -> void:
	var validation: int = _validate_sampled_axis(x_sampled, y_sampled)
	if not validation == OK:
		printerr("Cannot plot points for invalid dataset! Error: %s" % validation)
		return
	
	if y_sampled.values[0] is Array:
		for yxi in y_sampled.values.size():
			for i in y_sampled.values[yxi].size():
				var real_point_val: Pair = Pair.new(x[i], y[yxi][i])
				var sampled_point_pos: Vector2 = Vector2(x_sampled.values[i], y_sampled.values[yxi][i])
				var point: Point = Point.new(sampled_point_pos, real_point_val)
				_draw_point(point, yxi)
	else:
		for i in y_sampled.values.size():
			var real_point_val: Pair = Pair.new(x[i], y[i])
			var sampled_point_pos: Vector2 = Vector2(x_sampled.values[i], y_sampled.values[i])
			var point: Point = Point.news(sampled_point_pos, real_point_val)
			_draw_point(point, i)
