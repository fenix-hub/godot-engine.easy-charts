extends HBoxContainer
class_name FunctionLabel

signal clicked

@onready var type_label: FunctionTypeLabel = $FunctionType
@onready var name_label: Label = $FunctionName

func init_label(function: Function) -> void:
	type_label.type = function.get_type()
	type_label.color = function.get_color()
	type_label.marker = function.get_marker()
	type_label.icon = function.get_icon()

	name_label.text = function.name
	name_label.set("theme_override_colors/font_color", get_theme_color("text_color", "Chart"))

	_on_function_visibilty_changed(function.get_visibility())
	function.visibility_changed.connect(_on_function_visibilty_changed)

func init_clabel(type: int, color: Color, name: String) -> void:
	type_label.type = type
	type_label.color = color
	type_label.marker = Function.Marker.NONE
	type_label.indicator_visible = true

	name_label.text = name
	name_label.set("theme_override_colors/font_color", get_theme_color("text_color", "Chart"))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()

func _on_function_visibilty_changed(visible: bool) -> void:
	type_label.indicator_visible = visible
