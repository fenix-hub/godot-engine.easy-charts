@tool
extends PanelContainer
class_name DataTooltip

var gap: float = 15

@onready var x_lbl: Label = $PointData/x
@onready var y_lbl: Label = $PointData/Value/y
@onready var func_lbl: Label = $PointData/Value/Function
@onready var function_type_label: FunctionTypeLabel = $PointData/Value/FunctionTypeLabel

func _ready():
	hide()
	update_size()

func update_position(position: Vector2) -> void:
	if (position.x + gap + size.x) > get_parent().size.x:
		self.position = position - Vector2(size.x + gap, (get_rect().size.y / 2))
	else:
		self.position = position + Vector2(15, - (get_rect().size.y / 2))

func set_font(font: FontFile) -> void:
	theme.set("default_font", font)

func update_values(x: String, y: String, function: Function, color: Color) -> void:
	x_lbl.set_text(x)
	y_lbl.set_text(y)
	func_lbl.set_text(function.name)
	function_type_label.color = color
	function_type_label.marker = function.get_marker()
	function_type_label.type = function.get_type()
	function_type_label.icon = function.get_icon()
	function_type_label.indicator_visible = true

func update_size():
	x_lbl.set_text("")
	y_lbl.set_text("")
	func_lbl.set_text("")
	size = Vector2.ZERO

func _on_DataTooltip_visibility_changed():
	if not visible:
		update_size()
