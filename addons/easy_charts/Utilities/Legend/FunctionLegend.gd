extends VBoxContainer

onready var Function : Label = $Function
onready var FunctionColor : ColorRect = $Color

var text : String
var color : Color
var font_color : Color
var font : Font

func _ready():
	Function.set("custom_fonts/font",font)
	Function.set("custom_colors/font_color",font_color)
	Function.set_text(text)
	FunctionColor.set_frame_color(color)

func create_legend(text : String, color : Color, font : Font, font_color : Color):
	self.text = text
	self.color = color
	self.font_color = font_color
	self.font = font
