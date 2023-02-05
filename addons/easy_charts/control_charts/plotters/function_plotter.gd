extends Control
class_name FunctionPlotter

signal point_entered(point, function)
signal point_exited(point, function)

var function: Function
var x_domain: Dictionary
var y_domain: Dictionary

var points: Array
var points_positions: PoolVector2Array
var focused_point: Point

var point_size: float

func configure(function: Function) -> void:
	self.function = function
	self.point_size = function.props.get("point_size", 3.0)

func update_values(x_domain: Dictionary, y_domain: Dictionary) -> void:
	self.x_domain = x_domain
	self.y_domain = y_domain
	update()

func _draw() -> void:
	var box: Rect2 = get_parent().get_parent().get_plot_box()
	var x_sampled_domain: Dictionary = { lb = box.position.x, ub = box.end.x }
	var y_sampled_domain: Dictionary = { lb = box.end.y, ub = box.position.y }
	sample(x_sampled_domain, y_sampled_domain)

func sample(x_sampled_domain: Dictionary, y_sampled_domain: Dictionary) -> void:
	points = []
	points_positions = []
	for i in function.x.size():
		var position: Vector2 = Vector2(
			ECUtilities._map_domain(function.x[i], x_domain, x_sampled_domain),
			ECUtilities._map_domain(function.y[i], y_domain, y_sampled_domain)
		)
		points.push_back(Point.new(position, { x = function.x[i], y = function.y[i] }))
		points_positions.push_back(position)


