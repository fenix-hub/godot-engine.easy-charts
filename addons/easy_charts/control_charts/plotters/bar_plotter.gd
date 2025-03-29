extends FunctionPlotter
class_name BarPlotter

signal point_entered(point, function)
signal point_exited(point, function)

var bar_size: float

var _bars_rects: Array
var _focused_bar_midpoint: Point

func _draw() -> void:
	super._draw()
	sample()
	_draw_bars()

func sample() -> void:
	var bar_size := function.props.get("bar_size", 5.0) as float

	var bar_functions: Array[Function] = chart.get_functions_by_type(Function.Type.BAR)
	var bar_function_count = bar_functions.size()
	var index: int
	for i in range(0, bar_function_count):
		if bar_functions[i] == self.function:
			index = i
			break

	var id := function.props.get("id", 0) as int
	var x_offset_in_px := (id - index) * bar_size * 2

	var box: Rect2 = get_box()
	var x_sampled_domain := ChartAxisDomain.from_bounds(box.position.x, box.end.x)
	var y_sampled_domain := ChartAxisDomain.from_bounds(box.end.y, box.position.y)

	_bars_rects = []
	for i in function.__x.size():
		var x_value_in_px := ECUtilities._map_domain(i, x_domain, x_sampled_domain)
		var x_next_in_px := ECUtilities._map_domain(i + 1, x_domain, x_sampled_domain)
		var x_in_px := x_value_in_px + 0.5 * (x_next_in_px - x_value_in_px) - x_offset_in_px

		var y_in_px := ECUtilities._map_domain(function.__y[i], y_domain, y_sampled_domain)
		var y_zero_in_px := ECUtilities._map_domain(0.0, y_domain, y_sampled_domain)

		_bars_rects.append(Rect2(
			Vector2(x_in_px - bar_size, y_in_px),
			Vector2(bar_size * 2, y_zero_in_px - y_in_px)
		))

func _draw_bars() -> void:
	for bar in _bars_rects:
		draw_rect(bar, function.get_color())

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		for i in _bars_rects.size():
			if _bars_rects[i].grow(5).abs().has_point(get_relative_position(event.position)):
				var point: Point = Point.new(_bars_rects[i].get_center(), { x = i, y = function.__y[i]})
				if _focused_bar_midpoint == point:
					return
				else:
					_focused_bar_midpoint = point
					point_entered.emit(point, function)
					return
		# Mouse is not in any point's box
		point_exited.emit(_focused_bar_midpoint, function)
		_focused_bar_midpoint = null
