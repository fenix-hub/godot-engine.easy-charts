extends Chart
class_name ScatterChartBase

# Base Class to be inherited by any chart that wants to plot points or series 
# of points in a two-variable space. It handles basic data structure and grid 
# layout and leaves to child classes the more specific behaviour.

var x_values := []
var y_values := []
#Stored in the form of [[min_func1, min_func2, min_func3, ...], [max_func1, max_func2, ...]]
var x_domain := [[], []]
var y_domain := [[], []]

var x_range : PoolRealArray = [0, 0]
var y_range : PoolRealArray = [0, 0]
var autoscale_x = true
var autoscale_y = true


func build_property_list():
	property_list.clear()
	
	# Chart Properties
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_CATEGORY,
		"name": get_name(),
		"type": TYPE_STRING
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Properties/are_values_columns",
		"type": TYPE_BOOL
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "-1,100,1",
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Properties/labels_index",
		"type": TYPE_INT
	})
	
	# Chart Display
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Display/autoscale_x",
		"type": TYPE_BOOL
	})
	if not autoscale_x: 
		property_list.append(
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Display/min_x_range",
			"type": TYPE_REAL
		})
		property_list.append(
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Display/max_x_range",
			"type": TYPE_REAL
		})
	property_list.append(
	{
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.001, 10",
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Display/x_decim",
		"type": TYPE_REAL
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Display/autoscale_y",
		"type": TYPE_BOOL
	})
	if not autoscale_y:
		property_list.append(
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Display/min_y_range",
			"type": TYPE_REAL
		})
		property_list.append(
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Display/max_y_range",
			"type": TYPE_REAL
		})
	property_list.append(
	{
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0.001, 10",
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Display/y_decim",
		"type": TYPE_REAL
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Display/show_points",
		"type": TYPE_BOOL
	}
	)

	
		
	# Chart Style
	property_list.append(
	{ 
		"hint": 24, 
		"hint_string": ("%d/%d:%s"
		%[TYPE_INT, PROPERTY_HINT_ENUM,
		PoolStringArray(Point.SHAPES.keys()).join(",")]),
		"name": "Chart_Style/points_shape", 
		"type": TYPE_ARRAY, 
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/function_colors",
		"type": TYPE_COLOR_ARRAY
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/box_color",
		"type": TYPE_COLOR
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1, 100, 1",
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/grid_lines_width",
		"type": TYPE_INT
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/v_lines_color",
		"type": TYPE_COLOR
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/h_lines_color",
		"type": TYPE_COLOR
	})
	property_list.append(
	{
		"class_name": "Font",
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "Font",
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/font",
		"type": TYPE_OBJECT
	})
	property_list.append(
	{
		"class_name": "Font",
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "Font",
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/bold_font",
		"type": TYPE_OBJECT
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/font_color",
		"type": TYPE_COLOR
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/use_template",
		"type": TYPE_BOOL
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": PoolStringArray(ECUtilities.templates.keys()).join(","),
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/template",
		"type": TYPE_INT
	})
	
	# Chart Modifiers
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Modifiers/treshold",
		"type": TYPE_VECTOR2
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Modifiers/only_disp_values",
		"type": TYPE_VECTOR2
	})
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Modifiers/invert_chart",
		"type": TYPE_BOOL
	})


func _set(property, value):
	match property:
		"Chart_Display/show_points":
			show_points = value
			return true
		"Chart_Display/autoscale_x":
			autoscale_x = value
			build_property_list()
			property_list_changed_notify()
			return true
		"Chart_Display/autoscale_y":
			autoscale_y = value
			build_property_list()
			property_list_changed_notify()
			return true
		"Chart_Display/min_x_range":
			x_range[0] = value
			return true
		"Chart_Display/max_x_range":
			x_range[1] = value
			return true
		"Chart_Display/min_y_range":
			y_range[0] = value
			return true
		"Chart_Display/max_y_range":
			y_range[1] = value
			return true


func _get(property):
	match property:
		"Chart_Display/show_points":
			return show_points
		"Chart_Display/autoscale_x":
			return autoscale_x
		"Chart_Display/autoscale_y":
			return autoscale_y
		"Chart_Display/min_x_range":
			return x_range[0]
		"Chart_Display/max_x_range":
			return x_range[1]
		"Chart_Display/min_y_range":
			return y_range[0]
		"Chart_Display/max_y_range":
			return y_range[1]

func plot_function(id: String, x:Array, y:Array, param_dic := {}):
	# Add a function to the chart. If no identifier (label) is given a generic one
	# is generated.
	# param_dic is a dictionary with specific parameters to this curve
	
	if x.empty() or y.empty():
		ECUtilities._print_message("Can't plot a chart with an empty Array.",1)
		return
	elif x.size() != y.size():
		ECUtilities._print_message("Can't plot a chart with x and y having different number of elements.",1)
		return
	
	id = generate_identifier() if id.empty() else id
	
	if y_labels.has(id):
		ECUtilities._print_message("The identifier %s is already used. Please use a different one." % id,1)
		return
	
	y_domain[0].append(null)
	y_domain[1].append(null)
	x_domain[0].append(null)
	x_domain[1].append(null)
	
	x_values.append_array(x)
	y_values = y
	
	populate_x_datas()
	populate_y_datas()
	
	calculate_range(id)
	calculate_tics()
	redraw_plot()
	update()

func _slice():
	if only_disp_values.x < x_values.size() and only_disp_values.x != 0:
		x_values.pop_front()
		for y_data in y_datas:
			y_data.pop_front()

func update_functions(new_x, new_y : Array, param_dic : = {}) :
	assert(new_y.size() == y_labels.size(), 
	"new values array size (%s) must match Labels size (%s)"%[new_y.size(), y_labels.size()])
	_slice()
	x_values.append(new_x)
	
	for function in y_datas.size():
		y_datas[function].append(new_y[function])
		
		calculate_range(y_labels[function])
	calculate_tics()
	redraw_plot()
	update()


func update_function(id: String, new_x, new_y, param_dic := {}) -> void:
	var function = y_labels.find(id)
	
	if function == -1: #Not found
		ECUtilities._print_message("The identifier %s does not exist." % id,1)
		return
	
	_slice()
	for y_data_i in range(0, y_datas.size()):
		if y_data_i == function: y_datas[y_data_i].append(new_y)
		else: y_datas[y_data_i].append(y_datas[y_data_i][y_datas[y_data_i].size()-1])
	
	calculate_range(id)
	calculate_tics()
	redraw_plot()
	update()

func delete_function(id: String):
	var function = y_labels.find(id)
	
	if function == -1: #Not found
		ECUtilities._print_message("The identifier %s does not exist." % id,1)
		return
	
#	y_labels.remove(function)
	x_datas.remove(function)
	y_datas.remove(function)
	y_domain[0].remove(function)
	y_domain[1].remove(function)
	x_domain[0].remove(function)
	x_domain[1].remove(function)
	function_colors.remove(function)
	
	calculate_tics()
	redraw_plot()
	update()

func generate_identifier():
	#TODO: Check if the identifier generated already exist (given by the user)
	return "f%d" % (y_labels.size() + 1)

func populate_x_datas():
	x_labels = x_values
	x_datas.append(x_values)

func populate_y_datas():
	y_labels.append(y_values.pop_front() as String)
	
	for val in y_values.size():
		y_values[val] = y_values[val] as float
	
	y_datas.append(y_values)

func structure_data(database : Array):
	# @labels_index can be either a column or a row relative to x values
	# @y_values can be either a column or a row relative to y values
	
	#This is done to make sure this arrays are empty on subsecuent calls of this function.
	#This function is called from the "old" methods such as plot_from_array and 
	#for the moment it doesn't clean this variables on clean_variable.
	
	x_domain = [[], []]
	y_domain = [[], []]
	
	var database_size = range(database.size())
	if database_size.has(labels_index):
		x_values = database[labels_index]
		x_label = x_values.pop_front() as String
		database_size.erase(labels_index) #Remove x row from the iterator
	for size in database_size:
		populate_x_datas()
		y_values = database[size]
		populate_y_datas()
	
	for function in y_labels:
		y_domain[0].append(null)
		y_domain[1].append(null)
		x_domain[0].append(null)
		x_domain[1].append(null)
		calculate_range(function)
	
	calculate_tics()


func calculate_range(id):
	# Calculate the domain of the given function in the x and y axis
	# and updates the range value
	
	var function = y_labels.find(id)
	
	y_domain[0][function] = y_datas[function].min()
	y_domain[1][function] = y_datas[function].max()
	
	x_domain[0][function] = x_datas[function].min()
	x_domain[1][function] = x_datas[function].max()
	

func calculate_tics():
	y_chors.clear()
	x_chors.clear()
	
	# Chose the min/max from all functions
	if autoscale_x:
		x_range = [x_domain[0].min() if not origin_at_zero else 0, x_domain[1].max()]
	if autoscale_y:
		y_range = [y_domain[0].min() if not origin_at_zero else 0, y_domain[1].max()]
	
	
	y_margin_min = y_range[0]
	var y_margin_max = y_range[1]
	v_dist = y_decim * pow(10.0, calculate_position_significant_figure(y_margin_max - y_margin_min) - 1)
	
	# There are three cases of min/max:
	# 		For +/+ and -/- we just do the usual and draw tics from min to max
	# 		But for the -/+ we do in two times to force the 0 to appear so it is
	#		easier to read. Then we draw the negative from 0 to min and the positives
	#		from 0 to max without drawing the 0 again
	if y_margin_min < 0 and y_margin_max >= 0:
		calculate_interval_tics(0, y_margin_min, -v_dist, y_chors) #Negative tics
		calculate_interval_tics(0, y_margin_max, v_dist, y_chors, false) #Positive tics
		y_chors.sort()
		y_margin_min = min(y_margin_min, y_chors[0])
	else:
		calculate_interval_tics(y_margin_min, y_margin_max, v_dist, y_chors)
	for i in y_chors.size():
		y_chors[i] = String(y_chors[i]) #Can't cast directly on calculate_interval_tics because it mess up with the sorting 
	x_chors = x_labels.duplicate(true)


func build_chart():
	var longest_y_tic = 0
	for y_tic in y_chors:
		var length = font.get_string_size(str(y_tic)).x
		if length > longest_y_tic:
			longest_y_tic = length

	OFFSET.x = longest_y_tic + tic_length + 2 * label_displacement
	OFFSET.y = font.get_height() + tic_length + label_displacement
	
	SIZE = get_size() - Vector2(OFFSET.x, 0)
	origin = Vector2(OFFSET.x, SIZE.y - OFFSET.y)


func count_functions():
	functions = y_labels.size()


# Calculate distance in pixel between 2 consecutive values/datas
func calculate_pass():
	if x_chors.size() > 0:
		x_pass = (SIZE.x - OFFSET.x) / (x_chors.size() - 1 if x_chors.size() > 1 else x_chors.size())
	if y_chors.size() > 0:
		y_pass = (origin.y - ChartName.get_rect().size.y * 2) / (y_chors.size() - 1 if y_chors.size() > 1 else y_chors.size())


# Calculate all Points' coordinates in the dataset
# and display them inside the chart
func calculate_coordinates():
	point_values.clear()
	point_positions.clear()
	
	for _i in y_labels.size():
		point_values.append([])
		point_positions.append([])
	
	for function in y_labels.size():
		for val in x_datas[function].size():
			var value_x = (int(x_datas[function][val]) - x_margin_min) * x_pass / h_dist if h_dist else \
					val * x_pass
			var value_y = (y_datas[function][val] - y_margin_min) * y_pass / v_dist if v_dist else 0
	
			point_values[function].append([x_datas[function][val], y_datas[function][val]])
			point_positions[function].append(Vector2(value_x + origin.x, origin.y - value_y))

# Draw the grid lines for the chart
func draw_grid():
	# ascisse
	for p in x_chors.size():
		var point : Vector2 = origin + Vector2(p * x_pass, 0)
		var size_text : Vector2 = font.get_string_size(str(x_chors[p]))
		# v grid
		draw_line(point, point - Vector2(0, SIZE.y - OFFSET.y), v_lines_color, grid_lines_width, true)
		# ascisse
		draw_line(point + Vector2(0, tic_length), point, v_lines_color, grid_lines_width, true)
		draw_string(font, point + Vector2(-size_text.x / 2, size_text.y + tic_length),
				str(x_chors[p]), font_color)
	
	# ordinate
	for p in y_chors.size():
		var point : Vector2 = origin - Vector2(0, p * y_pass)
		var size_text := Vector2(font.get_string_size(y_chors[p]).x, font.get_ascent()) #The y should be ascent instead full height to get correctly centered
		
		# h grid
		draw_line(point, point + Vector2(SIZE.x - OFFSET.x, 0), h_lines_color, grid_lines_width, true)
		# ordinate
		draw_line(point, point + Vector2(-tic_length, 0), h_lines_color, grid_lines_width, true)
		draw_string(font, point + Vector2(-size_text.x - tic_length - label_displacement, 
				size_text.y / 2), y_chors[p], font_color)


# Draw chart outlines containing the current plot
func draw_chart_outlines():
	draw_line(origin, SIZE-Vector2(0, OFFSET.y), box_color, 1, true)
	draw_line(origin, Vector2(OFFSET.x, 0), box_color, 1, true)
	draw_line(Vector2(OFFSET.x, 0), Vector2(SIZE.x, 0), box_color, 1, true)
	draw_line(Vector2(SIZE.x, 0), SIZE - Vector2(0, OFFSET.y), box_color, 1, true)

# Draw the points using their coordinates and information, 
# inside a PointContainer
func draw_points():
	for function in point_values.size():
		var PointContainer : Control = Control.new()
		Points.add_child(PointContainer)
		
		for function_point in point_values[function].size():
			var point : Point = point_node.instance()
			point.connect("_point_pressed",self,"point_pressed")
			point.connect("_mouse_entered",self,"show_data")
			point.connect("_mouse_exited",self,"hide_data")
			
			point.create_point(points_shape[function], function_colors[function], 
			Color.white, point_positions[function][function_point], 
			point.format_value(point_values[function][function_point], false, false), 
			y_labels[function])
			
			PointContainer.add_child(point)

# Draw the tresholds (if set)
func draw_treshold():
	if v_dist != 0:
		treshold_draw = Vector2((treshold.x * x_pass) + origin.x ,origin.y - ((treshold.y * y_pass)/v_dist))
		if treshold.y != 0:
			draw_line(Vector2(origin.x, treshold_draw.y), Vector2(SIZE.x, treshold_draw.y), Color.red, 0.4, true)
		if treshold.x != 0:
			draw_line(Vector2(treshold_draw.x, 0), Vector2(treshold_draw.x, SIZE.y - OFFSET.y), Color.red, 0.4, true)


func calculate_position_significant_figure(number):
	return floor(log(abs(number))/log(10) + 1) #If number = 0 Godot returns -#INF and it behaves correctly on the pow call on calculate_tics


func calculate_interval_tics(v_from:float, v_to:float, dist:float, chords:Array, include_first := true):
	# Appends to array chords the tics calculated between v_from and v_to with
	# a given distance between tics.
	#include_first is used to tell if v_from should be appended or ignored
	
	var multi = 0
	var p = (dist * multi) + v_from
	var missing_tics = p < v_to if dist > 0 else p > v_to
	if include_first:
		chords.append(p)
	
	while missing_tics:
		multi += 1
		p = (dist * multi) + v_from
		missing_tics = p < v_to if dist > 0 else p > v_to
		chords.append(p)


func _to_string() -> String:
	return \
	"X DATA: %s\n" % str(x_datas) + \
	"Y DATA: %s\n" % str(y_datas) + \
	"X LABELS: %s\n" % str(x_labels) + \
	"Y LABELS: %s\n" % str(y_labels) 
