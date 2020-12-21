tool
extends Control
class_name Point

const OFFSET : Vector2 = Vector2(13,13)
var point_value : Array setget set_value,get_value
var point_position : Vector2
var color : Color setget set_color_point, get_color_point
var color_outline : Color
var function : String setget set_function, get_function

var mouse_entered : bool = false

enum SHAPES {
	Dot, Triangle, Square, Cross
}

var shape : int = 0 setget set_shape, get_shape

signal _mouse_entered(point)
signal _mouse_exited()
signal _point_pressed(point)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	if mouse_entered:
		draw_point(7,color_outline)
	draw_point(5,color)

func draw_point(size : float, color : Color):
	var factor : float
	match shape:
		SHAPES.Dot:
			draw_circle(OFFSET, size, color)
		SHAPES.Triangle:
			size+=6
			factor = 2
			draw_colored_polygon([
					OFFSET-Vector2(0,size/factor), OFFSET+Vector2(1,1)*size/factor, OFFSET-Vector2(1,-1)*size/factor
			], color,[],null,null,false)
		SHAPES.Square:
			size+=4
			factor = 2
			draw_colored_polygon([
					OFFSET-Vector2(1,1)*size/factor, OFFSET-Vector2(-1,1)*size/factor, OFFSET+Vector2(1,1)*size/factor, OFFSET-Vector2(1,-1)*size/factor
			], color,[],null,null,false)
		SHAPES.Cross:
			size+=2
			draw_line(OFFSET-Vector2(size,0), OFFSET+Vector2(size,0), color, size-5, true)
			draw_line(OFFSET-Vector2(0,size), OFFSET+Vector2(0,size), color, size-5, true)

func create_point(shape : int, color : Color, color_outline : Color, position : Vector2, value : Array, function : String):
	self.shape = shape
	self.color = color
	self.color_outline = color_outline
	self.point_position = position
	self.rect_position = point_position - OFFSET
	self.point_value = value
	self.function = function


func _on_Point_mouse_entered():
	mouse_entered = true
	emit_signal("_mouse_entered",self)
	update()

func _on_Point_mouse_exited():
	mouse_entered = false
	emit_signal("_mouse_exited")
	update()

func _on_Point_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == 1:
				emit_signal("_point_pressed",self)

func format_value(v : Array, format_x : bool, format_y : bool):
	var x : String = str(v[0])
	var y : String = str(v[1])
	
	if format_x:
		x = format(v[1])
	if format_y:
		y = format(v[1])
	
	return [x,y]

func format(n):
	n = str(n)
	var size = n.length()
	var s
	for i in range(size):
		if((size - i) % 3 == 0 and i > 0):
			s = str(s,",", n[i])
		else:
			s = str(s,n[i])
	
	return s.replace("Null","")

func set_value( v : Array = [] ) :
	point_value = v

func set_color_point( c : Color ):
	color = c

func set_function( f : String ):
	function = f

func set_shape(s : int):
	shape = s

# Public Getters
func get_value() -> Array:
	return point_value

func get_color_point() -> Color:
	return color

func get_function() -> String:
	return function

func get_shape() -> int:
	return shape
