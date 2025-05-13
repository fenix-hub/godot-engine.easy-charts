extends FunctionPlotter
class_name ScatterPlotter

signal point_entered(point, function)
signal point_exited(point, function)

var _points: Array[Point]
var points_positions: PackedVector2Array
var focused_point: Point

var _point_size: float

func _init(function: Function):
	super(function)
	_point_size = function.props.get("point_size", 3.0)

func _draw() -> void:
	super._draw()
	
	_sample()

	if function.get_marker() != Function.Marker.NONE:
		for point_position in points_positions:
			draw_function_point(point_position)

func _sample() -> void:
	var box: Rect2 = get_box()
	var x_sampled_domain := ChartAxisDomain.from_bounds(box.position.x, box.end.x)
	var y_sampled_domain := ChartAxisDomain.from_bounds(box.end.y, box.position.y)

	_points = []
	points_positions = []
	
	var lower_bound: int = 0
	if get_chart_properties().max_samples > 0:
		lower_bound = max(0, function.__x.size() - get_chart_properties().max_samples)

	for i in range(lower_bound, function.__x.size()):
		var _position: Vector2 = Vector2(
			ECUtilities._map_domain(float(function.__x[i]), x_domain, x_sampled_domain),
			ECUtilities._map_domain(float(function.__y[i]), y_domain, y_sampled_domain)
		)

		var point = Point.new(_position, { x = function.__x[i], y = function.__y[i] })

		# Don't sample outside y domain upper and lower bounds
		if point.position.y > y_sampled_domain.lb || point.position.y < y_sampled_domain.ub:
			continue

		_points.push_back(point)
		points_positions.push_back(_position)

func draw_function_point(point_position: Vector2) -> void:
	match function.get_marker():
		Function.Marker.SQUARE:
			draw_rect(
				Rect2(point_position - (Vector2.ONE * _point_size), (Vector2.ONE * _point_size * 2)), 
				function.get_color(), true, 1.0
			)
		Function.Marker.TRIANGLE:
			draw_colored_polygon(
				PackedVector2Array([
					point_position + (Vector2.UP * _point_size * 1.3),
					point_position + (Vector2.ONE * _point_size * 1.3),
					point_position - (Vector2(1, -1) * _point_size * 1.3)
				]), function.get_color(), [], null
			)
		Function.Marker.CROSS:
			draw_line(
				point_position - (Vector2.ONE * _point_size),
				point_position + (Vector2.ONE * _point_size),
				function.get_color(), _point_size, true
			)
			draw_line(
				point_position + (Vector2(1, -1) * _point_size),
				point_position + (Vector2(-1, 1) * _point_size),
				function.get_color(), _point_size / 2, true
			)
		Function.Marker.CIRCLE, _:
			draw_circle(point_position, _point_size, function.get_color())

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		for point in _points:
			if Geometry2D.is_point_in_circle(get_relative_position(event.position), point.position, _point_size * 4):
				if focused_point == point:
					return
				else:
					focused_point = point
					emit_signal("point_entered", point, function)
					return
		# Mouse is not in any point's box
		emit_signal("point_exited", focused_point, function)
		focused_point = null
