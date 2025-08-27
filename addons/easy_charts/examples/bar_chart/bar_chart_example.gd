extends Control

@onready var chart: Chart = $VBoxContainer/Chart

var functions: Array[Function]
var selected_functions: Array[Function]

var is_secondary_function_visible := true
var secondary_function: Function

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
	cp.y_scale = 10
	cp.draw_origin = true
	cp.draw_bounding_box = false
	cp.draw_vertical_grid = true
	cp.interactive = true # false by default, it allows the chart to create a tooltip to show point values
	cp.show_legend = true
	# and interecept clicks on the plot

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

	var secondary_function_y = ArrayOperations.add_float(
			ArrayOperations.multiply_float(
				ArrayOperations.cos(range(0, 24))
			, 100),
		110
	)
	secondary_function = Function.new(
		x, secondary_function_y, "Avg Duration",
		{
			type = Function.Type.LINE,
			marker = Function.Marker.CROSS,
			color = Color.DODGER_BLUE
		}
	)

	functions = [f1, f2, f3, f4, f5, f6]
	selected_functions = functions.slice(0, 2)
	_plot()

func _plot():
	# Now let's plot the selected bar functions + the line function
	var secondary_function_array: Array[Function] = []
	if is_secondary_function_visible:
		secondary_function_array = [secondary_function]

	chart.plot(selected_functions + secondary_function_array, cp)

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

func _on_show_line_chart_toggled(toggled_on: bool) -> void:
	is_secondary_function_visible = toggled_on
	_plot()


func _on_secondary_function_type_option_item_selected(index: int) -> void:
	is_secondary_function_visible = true
	match index:
		0: is_secondary_function_visible = false
		1: secondary_function.props.type = Function.Type.SCATTER
		2: secondary_function.props.type = Function.Type.LINE
		3: secondary_function.props.type = Function.Type.AREA
	_plot()
