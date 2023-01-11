extends Reference
class_name DrawingOptions

var points: bool = true
var grid: bool = false
var bounding_box: bool = true
var background: bool = true
var borders: bool = false
var ticks: bool = true
var labels: bool = true
var origin: bool = true

var colors: Dictionary = {
	bounding_box = Color.black,
	grid = Color.gray,
	functions = [Color.red, Color.green, Color.blue, Color.black]
}

var shapes: Array = [PointContainer.PointShape.CIRCLE, PointContainer.PointShape.SQUARE, PointContainer.PointShape.TRIANGLE, PointContainer.PointShape.CROSS]
var point_radius: float = 3.0
var font: BitmapFont = Label.new().get_font("")

func get_function_color(function_index: int) -> Color:
	return colors.functions[function_index] if function_index < colors.functions.size() else Color.black

func get_point_shape(function_index: int) -> int:
	return shapes[function_index] if function_index < shapes.size() else PointContainer.PointShape.CIRCLE
