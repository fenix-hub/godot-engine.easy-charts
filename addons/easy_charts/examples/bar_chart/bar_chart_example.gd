extends Control

@onready var chart: Chart = $VBoxContainer/Chart

var functions: Array[Function]
var selected_functions: Array[Function]
var line_function: Function

# Let's create our @x values.
var x: Array = range(0, 24).map(func(i: int) -> String: return "%d - %d h" % [i, i+1])

# And our y values.
var y1: Array = ArrayOperations.add_int(ArrayOperations.multiply_int(range(0, 24), 10), 4)
var y2: Array = ArrayOperations.add_int(ArrayOperations.multiply_int(range(0, 24), 5), 4)

var cp: ChartProperties

func _ready():
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	cp = ChartProperties.new()
	cp.colors.frame = Color("#161a1d")
	cp.colors.background = Color.TRANSPARENT
	cp.colors.grid = Color("#283442")
	cp.colors.ticks = Color("#283442")
	cp.colors.text = Color.WHITE_SMOKE
	cp.y_scale = 10
	cp.draw_origin = true
	cp.draw_bounding_box = false
	cp.draw_vertical_grid = true
	cp.interactive = true
	cp.show_legend = true

	# Let's add values to our functions
	# This will create a function with x and y values taken by the Arrays 
	# we have created previously. This function will also be named "Pressure"
	# as it contains 'pressure' values.
	# If set, the name of a function will be used both in the Legend
	# (if enabled thourgh ChartProperties) and on the Tooltip (if enabled).
	var f1 = Function.new(
		x, y1, "Users",
		{
			type = Function.Type.BAR,
			bar_size = 5,
			color = Color.SEA_GREEN,
		}
	)

	var f2 = Function.new(
		x, y2, "Impressions",
		{
			type = Function.Type.BAR,
			bar_size = 5,
			color = Color.SKY_BLUE,
		}
	)
	
	var f3 := Function.new(
		x, y1, "Conversions",
		{
			type = Function.Type.BAR,
			bar_size = 5,
			color = Color.YELLOW,
		}
	)

	var f4 := Function.new(
		x, y2, "Clicks",
		{
			type = Function.Type.BAR,
			bar_size = 5,
			color = Color.DARK_RED,
		}
	)
	
	var f5 := Function.new(
		x, y1, "Bounce Rate",
		{
			type = Function.Type.BAR,
			bar_size = 5,
			color = Color.CORAL
		}
	)
	
	var f6 = Function.new(
		x, y2, "New Users",
		{
			type = Function.Type.BAR,
			bar_size = 5,
			color = Color.PLUM
		}
	)

	var line_function_y = ArrayOperations.add_float(
			ArrayOperations.multiply_float(
				ArrayOperations.cos(range(0, 24))
			, 100),
		110
	)
	line_function = Function.new(
		x, line_function_y, "Avg Duration",
		{
			type = Function.Type.LINE,
			color = Color.DODGER_BLUE
		}
	)

	functions = [f1, f2, f3, f4, f5, f6]
	selected_functions = functions.slice(0, 2)
	_plot()

func _plot():
	# Now let's plot the selected bar functions + the line function
	var line_function_array: Array[Function] = [line_function]
	chart.plot(selected_functions + line_function_array, cp)

func _on_add_function():
	# Do not exceed the max number of functions
	if selected_functions.size() == functions.size():
		return

	selected_functions = functions.slice(0, selected_functions.size() + 1)
	_plot()


func _on_remove_function():
	# Ensure to always have at least one function to show
	if selected_functions.size() == 1:
		return

	selected_functions = functions.slice(0, selected_functions.size() - 1)
	_plot()


func _on_show_line_chart_check_button_toggled(toggled_on: bool) -> void:
	line_function.props.set("visible", toggled_on)
	_plot()
