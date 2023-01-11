extends Chart
class_name ScatterChart

signal point_entered(point)
signal point_exited(point)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func plot(x: Array, y: Array) -> void:
	self.x = x
	self.y = y
	
	_clear()
	_pre_process()
	update()

func _draw_point(point: Point, function_index: int) -> void:
	var point_container: PointContainer = point_container_scene.instance()
	$Points.add_child(point_container)
	point_container.set_point(
		point,
		drawing_options.colors.functions[function_index],
		drawing_options.shapes[function_index]
	)
	point_container.connect("point_entered", self, "_on_point_entered")
	point_container.connect("point_exited", self, "_on_point_exited")

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

func _on_point_entered(point: Point) -> void:
	emit_signal("point_entered", point)

func _on_point_exited(point: Point) -> void:
	emit_signal("point_exited", point)
