"""
A class representing a Pair (or Tuple) of values.
It is a lightweight class that can easily replace the improper and/or
unnecessary usage of a 2d Array (ex. `var arr: Array = [0.5, 0.6]`)
or of a Vector2 (ex. `var v2: Vector2 = Vector2(0.6, 0.8)`).
"""
extends Reference
class_name Pair

var left: float
var right: float

func _init(left: float = 0.0, right: float = 0.0) -> void:
	self.left = left
	self.right = right

func _to_string() -> String:
	return "[%.2f, %.2f]" % [self.left, self.right]
