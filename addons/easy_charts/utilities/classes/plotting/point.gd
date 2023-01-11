tool
extends Reference
class_name Point

var position: Vector2
var value: Pair

func _init(position: Vector2, value: Pair) -> void:
	self.value = value
	self.position = position

func _to_string() -> String:
	return "Value: %s\nPosition: %s" % [self.value, self.position]
