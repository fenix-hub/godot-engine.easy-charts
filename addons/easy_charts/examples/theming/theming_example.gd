extends Panel

@onready var _chart: Chart = %Chart

func _ready():
	var x: Array = ArrayOperations.multiply_float(range(-10, 11, 1), 0.5)
	var y: Array = ArrayOperations.multiply_int(ArrayOperations.cos(x), 20)
	var f1 = Function.new(x, y, "Pressure", { marker = Function.Marker.CIRCLE })

	_chart.set_y_domain(-50, 50)
	_chart.plot([f1])
