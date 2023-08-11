extends FunctionPlotter
class_name ScatterPlotter

signal point_entered(point, function)
signal point_exited()

var points: Array[Point]
var points_positions: PackedVector2Array

var _point_entered: Point

func _init(function: Function) -> void:
	super(function)

func update_values(x_domain: Dictionary, y_domain: Dictionary) -> void:
	var box: Rect2 = get_box()
	var x_sampled_domain: Dictionary = { lb = box.position.x, ub = box.end.x }
	var y_sampled_domain: Dictionary = { lb = box.end.y, ub = box.position.y }
	
	for i in function.x.size():
		var new_position: Vector2 = Vector2(
			ECUtilities._map_domain(float(function.x[i]), x_domain, x_sampled_domain),
			ECUtilities._map_domain(float(function.y[i]), y_domain, y_sampled_domain)
		)
		if i < points_positions.size():
			points_positions[i] = new_position
		else:
			points_positions.append(new_position)
		
		# If the Marker is NONE it's pointless to add points
		if function.get_marker() == Function.Marker.NONE:
			continue
		
		if get_chart_properties().use_nodes:
			if i < points.size():
				points[i].move_to_position(new_position, get_chart_properties().animated, sqrt(i) / 10.0)
			else:
				instantiate_point(
					create_point({ x = function.x[i], y = function.y[i] }, new_position),
					new_position, i
				)
		else:
			if i < points.size():
				points[i].set_position(new_position)
			else:
				create_point({ x = function.x[i], y = function.y[i] }, new_position)
	queue_redraw()


func _draw() -> void:
	# Should not draw anything if the marker is NONE
	if function.get_marker() == Function.Marker.NONE:
		return
	
	if get_chart_properties().use_nodes:
		return
	
	
	var _size: float = function.get_point_size()
	var color: Color = function.get_color()
	var points_positions: PackedVector2Array = get_points_positions()
	
	match function.get_marker():
		Function.Marker.SQUARE:
			for point_position in points_positions:
				draw_rect(
					Rect2(point_position - (Vector2.ONE * _size), (Vector2.ONE * _size * 2)), 
					color, true, 1.0
				)
		Function.Marker.TRIANGLE:
			for point_position in points_positions:
				draw_colored_polygon(
					PackedVector2Array([
						 point_position + (Vector2.UP * _size * 1.3),
						 point_position + (Vector2.ONE * _size * 1.3),
						 point_position - (Vector2(1, -1) * _size * 1.3)
					]), color, [], null
				)
		Function.Marker.CROSS:
			for point_position in points_positions:
				draw_line(
					 point_position - (Vector2.ONE * _size),
					 point_position + (Vector2.ONE * _size),
					color, _size, true
				)
				draw_line(
					 point_position + (Vector2(1, -1) * _size),
					 point_position + (Vector2(-1, 1) * _size),
					color, _size / 2, true
				)
		Function.Marker.CIRCLE, _:
			for point_position in points_positions:
				draw_circle(point_position, _size, color)

func create_point(value: Dictionary, pposition: Vector2) -> Point:
	var point: Point = Point.new(
		value, function.get_marker(), 
		function.get_point_size(), function.get_color()
	)
	point.set_position(pposition)
	points.append(point)
	return point

func instantiate_point(point: Point, at_position: Vector2, i: int) -> void:
	point.mouse_entered.connect(
		func(): point_entered.emit(point, function)
	)
	point.mouse_exited.connect(
		func(): point_exited.emit()
	)
	add_child(point)
	point.set_position(Vector2(get_box().end.x, at_position.y))
	point.move_to_position(
		at_position, get_chart_properties().animated, sqrt(i) / 10.0
	)

func get_points_positions() -> PackedVector2Array:
	return points_positions

func is_mouse_on_point(mouse_pos: Vector2, point_pos: Vector2) -> bool:
	return Geometry2D.is_point_in_circle(get_relative_position(mouse_pos), point_pos, function.get_point_size() * 4)

func _input(event: InputEvent) -> void:
	if points.is_empty():
		return
	
	if event is InputEventMouse:
		if not points.any(
			func(point: Point): 
				if is_mouse_on_point(event.position, point.position):
					if not _point_entered:
						point_entered.emit(point, function)
						_point_entered = point
					return true
				else:
					return false
		):
		# Mouse is not in any point's box
			if _point_entered:
				_point_entered = null
				point_exited.emit()
