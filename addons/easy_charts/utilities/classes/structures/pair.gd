extends RefCounted
class_name Pair

var left
var right

func _init(left = null, right = null) -> void:
	self.left = left
	self.right = right

func _format(val) -> String:
	var format: String = "%s"
	match typeof(val):
		TYPE_FLOAT:
			"%.2f"
	return format % val

func _to_string() -> String:
	return "[%s, %s]" % [_format(self.left), _format(self.right)]
