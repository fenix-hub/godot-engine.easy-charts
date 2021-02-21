tool
extends PanelContainer
class_name PointData

var value : String = ""
var position : Vector2 = Vector2()

var OFFSET : Vector2 = Vector2(15,35)
var GAP : Vector2 = Vector2(0,15)

onready var Data : Label = $PointData/Value/x
onready var Value : Label = $PointData/Value/y
onready var Function : Label = $PointData/Function

func _ready():
	hide()

func _process(delta):
	if get_global_mouse_position().y > OFFSET.y + GAP.y:
		rect_position = get_global_mouse_position() - OFFSET - GAP
	else:
		rect_position = get_global_mouse_position() + GAP*5 - OFFSET

func update_datas(point : Control):
	update_size()
	
	get("custom_styles/panel").set("bg_color",point.color)
	
	var font_color : Color
	if point.color.g < 0.75:
		font_color = Color(1,1,1,1)
	else:
		font_color = Color(0,0,0,1)
	Data.set("custom_colors/font_color",font_color)
	Value.set("custom_colors/font_color",font_color)
	Function.set("custom_colors/font_color",font_color)
	get("custom_styles/panel").set("border_color",font_color)
	
	Data.set_text(point.point_value[0]+":")
	Value.set_text(point.point_value[1])
	Function.set_text(point.function)
	update()
	show()

func update_slice_datas(slice : Slice):
	update_size()
	
	get("custom_styles/panel").set("bg_color",slice.color)
	
	var font_color : Color
	if slice.color.g < 0.75:
		font_color = Color(1,1,1,1)
	else:
		font_color = Color(0,0,0,1)
	Data.set("custom_colors/font_color",font_color)
	Value.set("custom_colors/font_color",font_color)
	Function.set("custom_colors/font_color",font_color)
	get("custom_styles/panel").set("border_color",font_color)
	
	Data.set_text(slice.x_value+":")
	Value.set_text(slice.y_value)
	Function.set_text(slice.function)
	update()
	show()

func update_size():
	OFFSET.x = get_size().x/2
	OFFSET.y = get_size().y 
	GAP.y = OFFSET.y/3
