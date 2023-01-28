extends Control

onready var chart: PieChart = $PieChart

func _ready():
	# Let's create our @x values
	var sizes: Array = [8, 16, 32, 64, 128]
	
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	var cp: ChartProperties = ChartProperties.new()
	cp.title = "Number of bits for operating systems"
	cp.functions_names = ["AMD1", "AMD2", "AMD3", "AMD4", "AMD5"]
	cp.interactive = true # false by default, it allows the chart to create a tooltip to show point values
	# and interecept clicks on the plot
	
	# Plot our data
	chart.plot(sizes, cp)
	
	# Uncommenting this line will show how real time data plotting works
	set_process(false)

func _process(delta: float):
	# This function updates the values of chart x, y, and x_labels array
	# and updaptes the plot
	var new_val: float = randi() % 64 + 64
	chart.values.append(new_val)
	chart.chart_properties.functions_names.append(str(new_val) + "s")
	chart.update()


func _on_CheckButton_pressed():
	set_process(not is_processing())
