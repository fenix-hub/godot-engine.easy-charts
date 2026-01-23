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

# Using function instead of  @onrady variable, to make it accesible
# within get and set text property accessors.
func _label() -> Label:
	return $Label

func _ready() -> void:
	_label().item_rect_changed.connect(_update_size)

func _update_size() -> void:
	if orientation == HORIZONTAL:
		custom_minimum_size.x = _label().size.x
		_label().rotation = 0
		_label().position = Vector2(0, 0)
	else:
		custom_minimum_size.x = _label().size.y
		_label().rotation = -0.5 * PI
		_label().position = Vector2(0, _label().size.x)

	print_debug("Size updated")
