extends Control

@onready var chart: Chart = $VBoxContainer/Chart

@export var blackbird_icon: Texture2D
@export var nightingale_icon: Texture2D

func _ready():
	# X values will be the hours of the day, starting with 0 ending on 23.
	var x: Array = range(0, 24).map(func(i) -> String: return "%d - %d h" % [i, i+1])

	# Arrays contain how many animals have been seen in each hour.
	var blackbird_spots: Array =   [0, 0, 0, 0, 0, 0, 0, 4, 5, 3, 6, 0, 0, 0, 2, 0, 0, 4, 5, 0, 0, 0, 0, 0]
	var nightingale_spots: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 2, 1, 0, 4, 4, 0, 3, 0, 0]

	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	var cp: ChartProperties = ChartProperties.new()
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
		{
			color = Color.YELLOW_GREEN,
			marker = Function.Marker.CIRCLE,
			type = Function.Type.SCATTER,
			icon = blackbird_icon
		}
	)

	var nightingale_function = Function.new(
		x,
		nightingale_spots,
		"Nightingale",
		{
			color = Color.INDIAN_RED,
			marker = Function.Marker.CROSS,
			type = Function.Type.SCATTER,
			icon = nightingale_icon
		}
	)

	# Configure the y axis. We set the scale and domain in such
	# that we get ticks only on integers, not on floats. 
	# We also configure the label function to not print decimal places.
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
	chart.y_labels_function = func(value: float): return str(int(value))

	# Now let's plot our data
	chart.plot([blackbird_function, nightingale_function], cp)
