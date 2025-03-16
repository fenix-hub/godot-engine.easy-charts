extends Control

@onready var chart: Chart = $VBoxContainer/Chart

func _ready():
	# X values will be the hours of the day, starting with 0 ending on 23.
	var x: Array = range(0, 24)

	# Arrays contain how many animals have been seen in each hour.
	var blackbird_spots: Array =   [0, 0, 0, 0, 0, 0, 0, 4, 5, 3, 6, 0, 0, 0, 2, 0, 0, 4, 5, 0, 0, 0, 0, 0]
	var nightingale_spots: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 2, 1, 0, 4, 4, 0, 3, 0, 0]

	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	var cp: ChartProperties = ChartProperties.new()
	cp.colors.frame = Color("#161a1d")
	cp.colors.background = Color.TRANSPARENT
	cp.colors.grid = Color("#283442")
	cp.colors.ticks = Color("#283442")
	cp.colors.text = Color.WHITE_SMOKE
	cp.draw_bounding_box = false
	cp.title = "Animal spots"
	cp.x_label = "Time"
	cp.y_label = "Spots"
	cp.interactive = true
	cp.show_legend = true
 
	# Let's add values to our functions
	var blackbird_function = Function.new(
		x,
		blackbird_spots,
		"Blackbird",
		{ color = Color.GREEN, marker = Function.Marker.CIRCLE, type = Function.Type.SCATTER }
	)

	var nightingale_function = Function.new(
		x,
		nightingale_spots,
		"Nightingale",
		{ color = Color.BLUE, marker = Function.Marker.CROSS, type = Function.Type.SCATTER }
	)

	# Now let's plot our data
	chart.y_labels_function = func(value: float): return str(int(value))

	# Configure the x axis so that there is one tick every two hours. This has to
	# be precise to ensure that no interpolation happens
	cp.x_scale = x.size() - 1
	chart.set_x_domain(0, x.size() - 1)
	chart.x_labels_function = func(value: float) -> String:
		return "%2d h" % round(value)

	# Configure the y axis 
	var y_max_value := 0
	for i in range(0, 24):
		if blackbird_spots[i] > y_max_value:
			y_max_value = blackbird_spots[i]
		if nightingale_spots[i] > y_max_value:
			y_max_value = nightingale_spots[i]
	# Add one or two on top so that we have some nice spacing
	y_max_value += 2 if (y_max_value % 2) == 0 else 1
	cp.y_scale = y_max_value / 2
	chart.set_y_domain(0, y_max_value)

	chart.plot([blackbird_function, nightingale_function], cp)
