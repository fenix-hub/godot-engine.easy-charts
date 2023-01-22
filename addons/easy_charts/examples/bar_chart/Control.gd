extends Control

onready var chart: BarChart = $BarChart

func _ready():
	# Let's create our @x values
	var x: Array = ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5"]
	# And our y values. It can be an n-size array of arrays.
	# NOTE: `x.size() == y.size()` or `x.size() == y[n].size()`
	var y: Array = [
		20, 10, -15, 30, 42
	]
	
	# Add some labels for the x axis, we don't want to use our x values array
	# they will be printed on the chart ticks instead of the value of the x axis.
	var x_labels: Array = ArrayOperations.suffix(x, "s")
	
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	var cp: ChartProperties = ChartProperties.new()
	cp.grid = true
	cp.title = "Air Quality Monitoring"
	cp.x_label = ("Days")
	cp.x_scale = 20
	cp.y_label = ("Sensor values")
	cp.y_scale = 10
	cp.points = false
	cp.interactive = true # false by default, it allows the chart to create a tooltip to show point values
	# and interecept clicks on the plot
	
	# Set the x_labels
#	$LineChart.x_labels = x_labels
	
	# Plot our data
	chart.plot(x, y, cp)
	
	# Uncommenting this line will show how real time data plotting works
	set_process(false)

func _process(delta: float):
	# This function updates the values of chart x, y, and x_labels array
	# and updaptes the plot
	var new_val: String = "Day %s" % (chart.x.size() + 1)
	chart.x.append(new_val)
	chart.y.append(randi() % 40)
	chart.update()


func _on_CheckButton_pressed():
	set_process(not is_processing())
