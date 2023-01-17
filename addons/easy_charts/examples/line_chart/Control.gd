extends Control

func _ready():
	# Let's create our @x values
	var x: Array = ArrayOperations.multiply_float(range(-2*PI, +2*PI, 1), 0.5)
	# And our y values. It can be an n-size array of arrays.
	# NOTE: `x.size() == y.size()` or `x.size() == y[n].size()`
	var y: Array = [
		ArrayOperations.multiply_float(ArrayOperations.cos(x), 1.0),
		ArrayOperations.multiply_float(ArrayOperations.sin(x), 1.0)
	]
	
	# Add some labels for the x axis, we don't want to use our x values array
	# they will be printed on the chart ticks instead of the value of the x axis.
	var x_labels: Array = ArrayOperations.suffix(x, "s")
	
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	var cp: ChartProperties = ChartProperties.new()
	cp.grid = false
	cp.origin = true
	cp.title = "Air Quality Monitoring"
	cp.x_label = ("Time")
	cp.x_scale = 10
	cp.y_label = ("Sensor values")
	cp.y_scale = 10
	cp.points = true
	cp.line_width = 2.0
	cp.point_radius = 2.5
	cp.use_splines = true
	cp.interactive = false # false by default, it allows the chart to create a tooltip to show point values
	# and interecept clicks on the plot
	
	# Set the x_labels
#	$LineChart.x_labels = x_labels
	
	# Plot our data
	$LineChart.plot(x, y, cp)
	
	# Uncommenting this line will show how real time data plotting works
	set_process(false)

func _process(delta: float):
	# This function updates the values of chart x, y, and x_labels array
	# and updaptes the plot
	var new_val: float = $LineChart.x.back() + 1
	$LineChart.x.append(new_val)
	$LineChart.y[0].append(cos(new_val))
	$LineChart.y[1].append(2 + sin(new_val))
	$LineChart.x_labels.append(str(new_val) + "s")
	$LineChart.update()


func _on_CheckButton_pressed():
	set_process(not is_processing())
