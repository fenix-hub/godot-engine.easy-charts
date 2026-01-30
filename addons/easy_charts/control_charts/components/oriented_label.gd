@tool
extends Control

@export
var text: String:
	get: return _label().text
	set(value):
		_label().text = value
		_update_size()

@export
var orientation: Orientation = HORIZONTAL:
	get: return orientation
	set(value):
		orientation = value
		_update_size()

# Using function instead of @onrady variable, because in editor, the
# text property is set before the _ready() function is invoked. Therefore,
# the @onready variable would not be initialized.
func _label() -> Label:
	return $Label

func _ready() -> void:
	_label().item_rect_changed.connect(_update_size)
	resized.connect(_update_size)

func _update_size() -> void:
	if orientation == HORIZONTAL:
		custom_minimum_size.x = _label().size.x
		_label().rotation = 0
		_label().position = Vector2(0, get_rect().get_center().y - _label().size.x)
	else:
		custom_minimum_size.x = _label().size.y
		_label().rotation = -0.5 * PI
		_label().position = Vector2(0, get_rect().get_center().y)
