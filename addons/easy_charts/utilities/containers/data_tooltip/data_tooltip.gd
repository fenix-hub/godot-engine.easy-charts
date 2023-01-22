tool
extends PanelContainer
class_name DataTooltip

var value : String = ""
var position : Vector2 = Vector2()

onready var x_lbl : Label = $PointData/x
onready var y_lbl : Label = $PointData/Value/y
onready var func_lbl : Label = $PointData/Value/Function
onready var color_rect: Panel = $PointData/Value/Color

func _ready():
	hide()
	update_size()

func _process(delta):
	if Engine.editor_hint:
		return
	rect_position = get_global_mouse_position() + Vector2(15, - (get_rect().size.y / 2))

func update_values(x: String, y: String, function: String, color: Color):
	x_lbl.set_text(x)
	y_lbl.set_text(y)
	func_lbl.set_text(function)
	color_rect.get("custom_styles/panel").set("bg_color", color)

func update_size():
	x_lbl.set_text("")
	y_lbl.set_text("")
	func_lbl.set_text("")
	rect_size = Vector2.ZERO

func _on_DataTooltip_visibility_changed():
	if not visible:
		update_size()
