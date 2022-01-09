extends Reference
class_name Slice

var x_value : String
var y_value : String
var from_angle : float
var to_angle : float
var function : String
var color : Color

func _init(x : String, y : String, from : float, to : float, fun : String, col : Color):
	x_value = x
	y_value = y
	from_angle = from
	to_angle = to
	function = fun
	color = col
