extends Control

@onready var chart: Chart = $VBoxContainer/Chart

func _ready():
	# Let's create our @x values
	var x: Array = range(0, 24).map(func(i: int) -> String: return "%d - %d h" % [i, i+1])
	
	# And our y values. It can be an n-size array of arrays.
	# NOTE: `x.size() == y.size()` or `x.size() == y[n].size()`
	var y1: Array = ArrayOperations.add_int(ArrayOperations.multiply_int(range(0, 24), 10), 4)
	var y2: Array = ArrayOperations.add_int(ArrayOperations.multiply_int(range(0, 24), 5), 4)
	
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	var cp: ChartProperties = ChartProperties.new()
	cp.colors.frame = Color("#161a1d")
	cp.colors.background = Color.TRANSPARENT
	cp.colors.grid = Color("#283442")
	cp.colors.ticks = Color("#283442")
	cp.colors.text = Color.WHITE_SMOKE
	cp.y_scale = 10
	cp.draw_origin = true
	cp.draw_bounding_box = false
	cp.draw_vertical_grid = true
	cp.interactive = true # false by default, it allows the chart to create a tooltip to show point values
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

	# Now let's plot our data
	chart.plot([f1, f2, f3, f4], cp)
