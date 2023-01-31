extends Control

onready var _title_lbl: Label = $Title
onready var _x_lbl: Label = $XLabel
onready var _y_lbl: Label = $YLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_font(font: DynamicFont) -> void:
	_title_lbl.set("custom_fonts/font", font)
	_x_lbl.set("custom_fonts/font", font)
	_y_lbl.set("custom_fonts/font", font)

func update_title(text: String, color: Color, position: Vector2, rotation: float = 0.0) -> void:
	_update_canvas_label(_title_lbl, text, color, position, rotation)

func update_y_label(text: String, color: Color, position: Vector2, rotation: float = 0.0) -> void:
	_update_canvas_label(_y_lbl, text, color, position, rotation)

func update_x_label(text: String, color: Color, position: Vector2, rotation: float = 0.0) -> void:
	_update_canvas_label(_x_lbl, text, color, position, rotation)

func _update_canvas_label(canvas_label: Label, text: String, color: Color, position: Vector2, rotation: float = 0.0) -> void:
	canvas_label.set_text(text)
	canvas_label.modulate = color
	canvas_label.rect_rotation = rotation
	canvas_label.rect_position = position
