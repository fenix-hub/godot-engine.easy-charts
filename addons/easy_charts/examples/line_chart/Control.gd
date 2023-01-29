extends Control

onready var chart: LineChart = $LineChart

func _ready():
	# Let's create our @x values
	var x: Array = range(0, 61)
	# And our y values. It can be an n-size array of arrays.
	# NOTE: `x.size() == y.size()` or `x.size() == y[n].size()`
	var y: Array = [
		range(0, 61)
	]
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	var cp: ChartProperties = ChartProperties.new()
	cp.grid = false
	cp.title = "Air Quality Monitoring"
	cp.x_label = ("Time")
	cp.x_scale = 10
	cp.y_label = ("Sensor values")
	cp.y_scale = 1
	cp.points = false
	cp.line_width = 2.0
	cp.point_radius = 2.5
	cp.use_splines = true
	cp.interactive = false # false by default, it allows the chart to create a tooltip to show point values
	# and interecept clicks on the plot
	
	
	# Plot our data
	chart.plot(x, y, cp)
	
	# Uncommenting this line will show how real time data plotting works
	set_process(false)

func _process(delta: float):
	# This function updates the values of chart x, y, and x_labels array
	# and updaptes the plot
	var new_val: float = chart.x.back() + 1
	chart.x.append(new_val)
	chart.y[0].append(cos(new_val))
	chart.update()


func _on_CheckButton_pressed():
	set_process(not is_processing())
