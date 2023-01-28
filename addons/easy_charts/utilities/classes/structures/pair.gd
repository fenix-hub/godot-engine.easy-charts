"""
A class representing a Pair (or Tuple) of values.
It is a lightweight class that can easily replace the improper and/or
unnecessary usage of a 2d Array (ex. `var arr: Array = [0.5, 0.6]`)
or of a Vector2 (ex. `var v2: Vector2 = Vector2(0.6, 0.8)`).
"""
extends Reference
class_name Pair

var left
var right

func _init(left = null, right = null) -> void:
	self.left = left
	self.right = right

func map(value: float, target: Pair) -> float:
	return range_lerp(value, self.left, self.right, target.left, target.right)

func _format(val) -> String:
	var format: String = "%s"
	match typeof(val):
		TYPE_REAL:
			"%.2f"
	return format % val

func _to_string() -> String:
	return "[%s, %s]" % [_format(self.left), _format(self.right)]
