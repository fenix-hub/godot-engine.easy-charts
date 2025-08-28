extends FunctionPlotter
class_name BarPlotter

signal point_entered(point, function)
signal point_exited(point, function)

var _bar_size: float

var _bars_rects: Array
var _focused_bar_midpoint: Point

func _init(chart: Chart, function: Function):
	super(chart, function)
	_bar_size = function.props.get("bar_size", 5.0) as float

func _draw() -> void:
	super._draw()
	_sample()
	_draw_bars()

func _sample() -> void:
	var box: Rect2 = get_box()
	var x_sampled_domain := ChartAxisDomain.from_bounds(box.position.x, box.end.x)
	var y_sampled_domain := ChartAxisDomain.from_bounds(box.end.y, box.position.y)

	_bars_rects = []
	var get_bar_left_padding = _get_bar_left_padding_function(x_sampled_domain)

	for i in function.__x.size():
		var x_in_px := x_domain.map_to(i, function.__x, x_sampled_domain)
		var y_in_px := y_domain.map_to(i, function.__y, y_sampled_domain)
		var y_zero_in_px := ECUtilities._map_domain(0.0, y_domain, y_sampled_domain)

		var left_padding_px := get_bar_left_padding.call(i)
		_bars_rects.append(Rect2(
			Vector2(x_in_px + left_padding_px, y_in_px),
			Vector2(_bar_size * 2, y_zero_in_px - y_in_px)
		))

func _draw_bars() -> void:
	for bar in _bars_rects:
		draw_rect(bar, function.get_color())

# Returns (value_index: int) -> float function that computes the left padding
# of bars depending on if bars are placed on ticks or centered between ticks.
func _get_bar_left_padding_function(x_sampled_domain) -> Callable:
	# Function for non-centered bars will simply use the bar size.
	if !chart.are_x_tick_labels_centered():
		return func(_value_index: int) -> float: return -_bar_size

	# Function for centered bars place bars next to each other between
	# tick labels. In the following, we pre-compute some values that will
	# be captured (and therefore cached) for the lambda.
	var bar_functions: Array[Function] = chart.get_functions_by_type(Function.Type.BAR)
	var function_index: int
	for i in range(0, bar_functions.size()):
		if bar_functions[i] == self.function:
			function_index = i
			break

	var total_bar_sizes := bar_functions.size() * _bar_size * 2
	var distance_between_ticks_px = \
		x_domain.map_to(1, function.__x, x_sampled_domain)\
		- x_domain.map_to(0, function.__x, x_sampled_domain)

	# Return the padding lambda for centered bars.
	return func(value_index: int) -> float:
		return 0.5 * (distance_between_ticks_px - total_bar_sizes) \
			+ function_index * _bar_size * 2

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		for i in _bars_rects.size():
			if _bars_rects[i].grow(5).abs().has_point(get_relative_position(event.position)):
				var point: Point = Point.new(_bars_rects[i].get_center(), { x = function.__x[i], y = function.__y[i]})
				if _focused_bar_midpoint == point:
					return
				else:
					_focused_bar_midpoint = point
					point_entered.emit(point, function)
					return
		# Mouse is not in any point's box
		point_exited.emit(_focused_bar_midpoint, function)
		_focused_bar_midpoint = null
