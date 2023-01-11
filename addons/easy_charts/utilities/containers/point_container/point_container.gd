extends Control
class_name PointContainer

signal point_entered(point)
signal point_exited(point)

enum PointShape {
	CIRCLE,
	TRIANGLE,
	SQUARE,
	CROSS
}

var point: Point
var color: Color
var radius: float
var shape: int
var label: String

func _ready():
	pass

func set_point(point: Point, color: Color = Color.black, shape: int = PointShape.CIRCLE, radius: float = 3.0) -> void:
	self.point = point
	self.color = color
	self.shape = shape
	self.radius = radius
	
	auto_pos(self.point.position)

func auto_pos(pos: Vector2) -> void:
	self.rect_position += pos

func _draw_bounding_box() -> void:
	var t_gr: Rect2 = get_global_rect()
	draw_rect(Rect2(Vector2.ZERO, get_rect().size), Color.black, false, 1, true)

func _draw_label() -> void:
	var lbl: Label = Label.new()
	add_child(lbl)
	lbl.rect_position += self.rect_size
	lbl.text = str(label)

func _draw_point() -> void:
	var point_rel_pos: Vector2 = self.rect_size * 0.5
	
	match self.shape:
		PointShape.CIRCLE:
			draw_circle(point_rel_pos, self.radius,  self.color)
		PointShape.SQUARE:
			draw_rect(Rect2(point_rel_pos * 0.5, point_rel_pos), self.color, true, 1.0, false)

func _draw():
#	_draw_bounding_box()
	_draw_point()
#	_draw_label()

func _on_PointContainer_mouse_entered():
	emit_signal("point_entered", self.point)

func _on_PointContainer_mouse_exited():
	emit_signal("point_exited", self.point)
