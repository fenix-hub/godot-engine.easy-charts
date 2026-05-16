extends FunctionPlotter
class_name RadarPlotter

signal point_entered(point, function)
signal point_exited(point, function)

var _axis_labels: Array = []
var _values: Array = []
var _center: Vector2 = Vector2.ZERO
var _radius: float = 0.0
var _points: Array[Point] = []
var _focused_index: int = -1
var _focused_point: Point

func _draw() -> void:
	super._draw()

	_extract_data()
	if _axis_labels.is_empty() or _values.is_empty():
		return

	var box := get_box()
	_center = box.get_center()
	_radius = minf(box.size.x, box.size.y) * 0.40
	if _radius <= 0.0:
		return

	if _should_draw_background_grid():
		_draw_radar_grid()
		_draw_scale_labels()
		_draw_axis_labels()

	_draw_series()


func _extract_data() -> void:
	_axis_labels = function.__x.duplicate()
	_values = function.__y.duplicate()


func _should_draw_background_grid() -> bool:
	if chart == null or chart.functions.is_empty():
		return true
	return chart.functions[0] == function


func _draw_radar_grid() -> void:
	var axis_count := _axis_labels.size()
	if axis_count < 3:
		return

	var grid_levels: int = int(function.props.get("radar_grid_levels", 5))
	var grid_color: Color = function.props.get("radar_grid_color", Color("#d9d9d9"))
	var axis_color: Color = function.props.get("radar_axis_color", Color("#d9d9d9"))

	for level in range(1, grid_levels + 1):
		var t: float = float(level) / float(grid_levels)
		var ring_points := _build_ring_points(axis_count, t)
		ring_points.push_back(ring_points[0])
		draw_polyline(ring_points, grid_color, 1.5, true)

	for i in range(axis_count):
		var direction := _get_axis_direction(i, axis_count)
		draw_line(_center, _center + (direction * _radius), axis_color, 1.2, true)


func _draw_scale_labels() -> void:
	if not bool(function.props.get("radar_show_scale_labels", true)):
		return

	var grid_levels: int = int(function.props.get("radar_grid_levels", 5))
	if grid_levels <= 0:
		return

	var max_value: float = float(function.props.get("radar_max_value", 100.0))
	var label_color: Color = function.props.get("radar_scale_label_color", Color("#888888"))
	var font: Font = get_chart_properties().font
	var font_size: int = max(10, get_chart_properties().font_size - 1)

	for level in range(1, grid_levels + 1):
		var ratio: float = float(level) / float(grid_levels)
		var label_value := int(round(max_value * ratio))
		var label := str(label_value)
		var label_position := _center + Vector2(0, -_radius * ratio)
		var label_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		draw_string(
			font,
			label_position + Vector2(6.0, label_size.y * 0.35),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			label_color
		)


func _draw_axis_labels() -> void:
	var axis_count := _axis_labels.size()
	if axis_count < 3:
		return

	var font: Font = get_chart_properties().font
	var font_size: int = get_chart_properties().font_size
	var text_color: Color = function.props.get("radar_label_color", Color("#666666"))

	for i in range(axis_count):
		var label := str(_axis_labels[i])
		var direction := _get_axis_direction(i, axis_count)
		var label_position := _center + (direction * (_radius + 22.0))
		var label_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		draw_string(
			font,
			label_position - Vector2(label_size.x * 0.5, -label_size.y * 0.33),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			text_color
		)


func _draw_series() -> void:
	var axis_count := _axis_labels.size()
	if axis_count < 3:
		return

	var points := PackedVector2Array()
	_points.clear()
	for i in range(axis_count):
		var normalized_value := clampf(float(_values[i]) / 100.0, 0.0, 1.0)
		var direction := _get_axis_direction(i, axis_count)
		var position := _center + (direction * _radius * normalized_value)
		points.push_back(position)
		_points.append(Point.new(position, { x = _axis_labels[i], y = _values[i] }))

	points.push_back(points[0])

	var line_color: Color = function.get_color()
	var fill_color: Color = line_color
	fill_color.a = float(function.props.get("radar_fill_alpha", 0.20))

	var fill_polygon := PackedVector2Array(points)
	fill_polygon.remove_at(fill_polygon.size() - 1)
	draw_colored_polygon(fill_polygon, fill_color)
	draw_polyline(points, line_color, function.get_line_width(), true)

	if function.get_marker() != Function.Marker.NONE:
		for i in range(fill_polygon.size()):
			var p := fill_polygon[i]
			draw_circle(p, 4.0, line_color)
			draw_circle(p, 2.2, Color.WHITE)
			if i == _focused_index:
				draw_circle(p, 7.0, Color(line_color.r, line_color.g, line_color.b, 0.25))
				draw_arc(p, 6.2, 0.0, TAU, 24, line_color, 1.8)


func _build_ring_points(axis_count: int, factor: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(axis_count):
		var direction := _get_axis_direction(i, axis_count)
		points.push_back(_center + (direction * _radius * factor))
	return points


func _get_axis_direction(index: int, axis_count: int) -> Vector2:
	var angle := -PI * 0.5 + TAU * (float(index) / float(axis_count))
	return Vector2(cos(angle), sin(angle))


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouse):
		return

	if _points.is_empty():
		return

	var local_mouse := get_relative_position(event.position)
	var hover_radius: float = float(function.props.get("radar_hover_radius", 12.0))

	var nearest_index := -1
	var nearest_distance := INF
	for i in range(_points.size()):
		var distance := local_mouse.distance_to(_points[i].position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = i

	if nearest_index >= 0 and nearest_distance <= hover_radius:
		if nearest_index == _focused_index:
			return

		_focused_index = nearest_index
		_focused_point = _points[nearest_index]
		point_entered.emit(_focused_point, function)
		queue_redraw()
		return

	if _focused_index != -1:
		point_exited.emit(_focused_point, function)
		_focused_index = -1
		_focused_point = null
		queue_redraw()
