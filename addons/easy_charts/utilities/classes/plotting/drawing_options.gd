extends Reference
class_name DrawingOptions

var points: bool = true
var grid: bool = false
var bounding_box: bool = true
var background: bool = true
var borders: bool = false
var ticks: bool = true
var labels: bool = true

var colors: Dictionary = {
	bounding_box = Color.black,
	grid = Color.gray,
	functions = [Color.red, Color.green, Color.blue]
}

var shapes: Array = [PointContainer.PointShape.CIRCLE, PointContainer.PointShape.SQUARE, PointContainer.PointShape.SQUARE]
var point_radius: float = 3.0
var font: Font = Label.new().get_font("")
