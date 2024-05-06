@tool
extends PanelContainer
class_name DataTooltip

var gap: float = 15

@onready var x_lbl : Label = $PointData/x
@onready var y_lbl : Label = $PointData/Value/y
@onready var func_lbl : Label = $PointData/Value/Function
@onready var color_rect: Panel = $PointData/Value/Color

func _ready():
    hide()
    update_size()

func update_position(position: Vector2) -> void:
    if (position.x + gap + size.x) > get_parent().size.x:
        self.position = position - Vector2(size.x + gap, (get_rect().size.y / 2))
    else:
        self.position = position + Vector2(15, - (get_rect().size.y / 2))

#func _process(delta):
#	if Engine.editor_hint:
#		return
#	rect_position = get_global_mouse_position() + Vector2(15, - (get_rect().size.y / 2))

func set_font(font: FontFile) -> void:
    theme.set("default_font", font)

func update_values(x: String, y: String, function_name: String, color: Color):
    x_lbl.set_text(x)
    y_lbl.set_text(y)
    func_lbl.set_text(function_name)
    color_rect.get("theme_override_styles/panel").set("bg_color", color)

func update_size():
    x_lbl.set_text("")
    y_lbl.set_text("")
    func_lbl.set_text("")
    size = Vector2.ZERO

func _on_DataTooltip_visibility_changed():
    if not visible:
        update_size()
