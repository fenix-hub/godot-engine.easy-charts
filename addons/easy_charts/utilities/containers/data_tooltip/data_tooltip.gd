tool
extends PanelContainer
class_name DataTooltip

var position : Vector2 = Vector2()
var gap: float = 15

onready var x_lbl : Label = $PointData/x
onready var y_lbl : Label = $PointData/Value/y
onready var func_lbl : Label = $PointData/Value/Function
onready var color_rect: Panel = $PointData/Value/Color

func _ready():
	hide()
	update_size()

func update_position(position: Vector2) -> void:
	if (position.x + gap + rect_size.x) > get_parent().rect_size.x:
		self.rect_position = position - Vector2(rect_size.x + gap, (get_rect().size.y / 2))
	else:
		self.rect_position = position + Vector2(15, - (get_rect().size.y / 2))

#func _process(delta):
#	if Engine.editor_hint:
#		return
#	rect_position = get_global_mouse_position() + Vector2(15, - (get_rect().size.y / 2))

func set_font(font: DynamicFont) -> void:
	theme.set("default_font", font)

func update_values(x: String, y: String, function_name: String, color: Color):
	x_lbl.set_text(x)
	y_lbl.set_text(y)
	func_lbl.set_text(function_name)
	color_rect.get("custom_styles/panel").set("bg_color", color)

func update_size():
	x_lbl.set_text("")
	y_lbl.set_text("")
	func_lbl.set_text("")
	rect_size = Vector2.ZERO

func _on_DataTooltip_visibility_changed():
	if not visible:
		update_size()
