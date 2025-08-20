extends HBoxContainer
class_name FunctionLabel

signal clicked

@onready var type_lbl: FunctionTypeLabel = $FunctionType
@onready var name_lbl: Label = $FunctionName

func init_label(function: Function) -> void:
	type_lbl.type = function.get_type()
	type_lbl.color = function.get_color()
	type_lbl.marker = function.get_marker()
	name_lbl.text = function.name
	name_lbl.set("theme_override_colors/font_color", get_parent().chart_properties.colors.text)

	type_lbl.indicator_visible = function.get_visibility()
	function.visibility_changed.connect(_on_function_visibilty_changed)

func init_clabel(type: int, color: Color, marker: int, name: String) -> void:
	type_lbl.type = type
	type_lbl.color = color
	type_lbl.marker = marker
	name_lbl.set_text(name)
	name_lbl.set("theme_override_colors/font_color", get_parent().chart_properties.colors.text)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()

func _on_function_visibilty_changed(visible: bool) -> void:
	type_lbl.indicator_visible = visible
