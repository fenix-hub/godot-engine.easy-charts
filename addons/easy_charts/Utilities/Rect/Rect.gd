extends Control

var OFFSET : Vector2 = Vector2()
var point_value : Array
var point_position : Vector2
var color : Color
var color_outline : Color
var function : String

var mouse_entered : bool = false


signal _mouse_entered()
signal _mouse_exited()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _draw():
	if mouse_entered:
		draw_rect(Rect2(rect_position - OFFSET,rect_size),color_outline,true,12,true)

func create_point(color : Color, color_outline : Color, position : Vector2, size : Vector2, value : Array, function : String):
	
	self.color = color
	self.color_outline = color_outline
	self.point_position = position
	self.rect_position = point_position - OFFSET
	self.rect_size = size
	self.point_value = value
	self.function = function

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

func _on_Rect_mouse_entered():
	mouse_entered = true
	emit_signal("_mouse_entered")
	update()

func _on_Rect_mouse_exited():
	mouse_entered = false
	emit_signal("_mouse_exited")
	update()
