extends Control
class_name Point

var value: Dictionary
var marker: Function.Marker
var _size: float
var color: Color
var size_multiplier: float = 8.0
var tween: Tween

func _init(value: Dictionary, marker: Function.Marker, _size: float, color: Color) -> void:
	self.value = value
	self.marker = marker
	self._size = _size
	self.color = color


func _ready() -> void:
	set_custom_minimum_size(Vector2.ONE * _size * size_multiplier)
	set_size(Vector2.ONE * _size * size_multiplier)
	update_minimum_size()

func _draw():
	var center: Vector2 = Vector2.ONE * _size * size_multiplier / 2
	match marker:
		Function.Marker.SQUARE:
			draw_rect(
				Rect2(center - (Vector2.ONE * _size), (Vector2.ONE * _size * 2)), 
				color, true, 1.0
			)
		Function.Marker.TRIANGLE:
			draw_colored_polygon(
				PackedVector2Array([
					 + (Vector2.UP * _size * 1.3),
					 + (Vector2.ONE * _size * 1.3),
					 - (Vector2(1, -1) * _size * 1.3)
				]), color, [], null
			)
		Function.Marker.CROSS:
			draw_line(
				 center - (Vector2.ONE * _size),
				 center + (Vector2.ONE * _size),
				color, _size, true
			)
			draw_line(
				 center + (Vector2(1, -1) * _size),
				 center + (Vector2(-1, 1) * _size),
				color, _size / 2, true
			)
		Function.Marker.CIRCLE, _:
			draw_circle(center, _size, color)
#	draw_rect(Rect2(Vector2.ZERO, Vector2.ONE * _size * size_multiplier), Color.RED, false, 1)

func move_to_position(next_position: Vector2, animated: bool = false, delay: float = 0.0) -> void:
	next_position -= Vector2.ONE * (_size * size_multiplier / 2)
	if animated:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(
			self, "position", next_position, 0.5
		).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_delay(delay)
	else:
		self.position = next_position

func get_chart_position() -> Vector2:
	return self.position + Vector2.ONE * (_size * size_multiplier / 2)

func _to_string() -> String:
	return "Point: %s" % self.value
