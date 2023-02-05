extends HBoxContainer
class_name FunctionLabel

onready var type: Label = $FunctionType
onready var name_lbl: Label = $FunctionName

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_label(function: Function) -> void:
	type.type = function.get_type()
	type.color = function.get_color()
	type.marker = function.get_marker()
	name_lbl.set_text(function.name)
	name_lbl.set("custom_colors/font_color", get_parent().chart_properties.colors.text)
