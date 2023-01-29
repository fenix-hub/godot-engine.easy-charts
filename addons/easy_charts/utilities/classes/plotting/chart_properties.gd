extends Reference
class_name ChartProperties

var title: String
var x_label: String
var y_label: String
var functions_names: PoolStringArray
 
var x_scale: float = 5.0
var y_scale: float = 2.0

# Scale type, 0 = linear | 1 = logarithmic
var x_scale_type: int = 0
var y_scale_type: int = 0

var borders: bool = false
var background: bool = true
var bounding_box: bool = true
var grid: bool = false
var ticks: bool = true
var labels: bool = true
var origin: bool = false
var points: bool = true
var interactive: bool = false

var use_splines: bool = false

var colors: Dictionary = {
	background = Color.white,
	bounding_box = Color.black,
	grid = Color.gray,
	functions = ["#36a2eb", "#ff6384", "#ff9f40", "#ffcd56", "#4bc0c0"]
}

var point_radius: float = 3.0
var line_width: float = 1.0
var bar_width: float = 10.0
var shapes: Array = [Point.Shape.CIRCLE, Point.Shape.SQUARE, Point.Shape.TRIANGLE, Point.Shape.CROSS]
var font: BitmapFont = Label.new().get_font("")

func get_function_color(function_index: int) -> Color:
	return colors.functions[function_index] if function_index < colors.functions.size() else Color.black

func get_function_name(function_idx: int) -> String:
	return functions_names[function_idx] if function_idx < functions_names.size() else "Function %s" % function_idx

func get_point_shape(function_index: int) -> int:
	return shapes[function_index] if function_index < shapes.size() else Point.Shape.CIRCLE

func get_string_size(text: String) -> Vector2:
	return font.get_string_size(text)
