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

	var box: Rect2 = get_box()
	var x_sampled_domain := ChartAxisDomain.from_bounds(box.position.x, box.end.x)
	var y_sampled_domain := ChartAxisDomain.from_bounds(box.end.y, box.position.y)

	_bars_rects = []
	for i in function.__x.size():
		var top: Vector2 = Vector2(
			ECUtilities._map_domain(i, x_domain, x_sampled_domain),
			ECUtilities._map_domain(function.__y[i], y_domain, y_sampled_domain)
		)
		var base: Vector2 = Vector2(top.x, ECUtilities._map_domain(0.0, y_domain, y_sampled_domain))
		_bars_rects.append(Rect2(Vector2(top.x - bar_size, top.y), Vector2(bar_size * 2, base.y - top.y)))

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
