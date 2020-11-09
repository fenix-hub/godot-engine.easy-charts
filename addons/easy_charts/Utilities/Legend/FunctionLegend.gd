tool
extends VBoxContainer
class_name LegendElement

onready var Function : Label = $Function
onready var FunctionColor : ColorRect = $Color

var function : String setget set_function, get_function
var color : Color setget set_function_color, get_function_color
var font_color : Color
var font : Font

func _ready():
	Function.set("custom_fonts/font",font)
	Function.set("custom_colors/font_color",font_color)
	Function.set_text(function)
	FunctionColor.set_frame_color(color)

func create_legend(text : String, color : Color, font : Font, font_color : Color):
	self.function = text
	self.color = color
	self.font_color = font_color
	self.font = font

func set_function( t : String ):
	function = t

func get_function() -> String:
	return function

func set_function_color( c : Color ):
	color = c

func get_function_color() -> Color:
	return color

func get_class() -> String:
	return "Legend Element"

func _to_string() -> String:
	return "%s (%s, %s) " % [get_class(), get_function(), get_function_color().to_html(true)]
