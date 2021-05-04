extends Chart
class_name ScatterChartBase

# Base Class to be inherited by any chart that wants to plot points or series 
# of points in a two-variable space. It handles basic data structure and grid 
# layout and leaves to child classes the more specific behaviour.

#Stored in the form of [[min_func1, min_func2, min_func3, ...], [max_func1, max_func2, ...]]
var x_domain := [[], []]
var y_domain := [[], []]

var x_range := [0, 0]
var y_range := [0, 0]
var autoscale_x = true
var autoscale_y = true


var property_list = []


func _init():
	build_property_list()


func build_property_list():
	property_list.clear()
	
	# Chart Properties
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_CATEGORY,
		"name": "ScatterChartBase",
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
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Properties/show_x_values_as_labels",
		"type": TYPE_BOOL
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
	
		
	# Chart Style
	property_list.append(
	{ 
		"hint": 24, 
		"hint_string": ("%d/%d:%s"
		%[TYPE_INT, PROPERTY_HINT_ENUM,
		PoolStringArray(PointShapes.keys()).join(",")]),
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
		"hint_string": PoolStringArray(Utilities.templates.keys()).join(","),
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


func plot():
	# Overwrites the method on Chart to make a reusable piece to be used internally
	# to do all calculations needed to replot.
	calculate_tics()
	build_chart()
	count_functions()
	calculate_pass()
	calculate_colors()
	calculate_coordinates()
	set_shapes()
	create_legend()
	emit_signal("chart_plotted",self)
	
	if not is_connected("item_rect_changed",self, "redraw"): connect("item_rect_changed", self, "redraw")


func plot_function(x:Array, y:Array, param_dic := {}):
	# Add a function to the chart. If no identifier (label) is given a generic one
	# is generated.
	# param_dic is a dictionary with specific parameters to this curve
	
	load_font()
	PointData.hide()
	var id := ""
	
	if x.empty() or y.empty():
		Utilities._print_message("Can't plot a chart with an empty Array.",1)
		return
	elif x.size() != y.size():
		Utilities._print_message("Can't plot a chart with x and y having different number of elements.",1)
		return
	
	for param in param_dic.keys():
		match param:
			"label":
				id = param_dic[param]
			"color":
				if function_colors.size() < functions + 1: #There is going to be a new function
					function_colors.append(param_dic[param])
				else:
					function_colors[functions] = param_dic[param]
	
	id = generate_identifier() if id.empty() else id
	
	if y_labels.has(id):
		Utilities._print_message("The identifier %s is already used. Please use a different one." % id,1)
		return
	
	y_domain[0].append(null)
	y_domain[1].append(null)
	x_domain[0].append(null)
	x_domain[1].append(null)
	
	x_datas.append(x)
	y_datas.append(y)
	y_labels.append(id)
	
	calculate_range(id)
	plot()


func update_function(id:String, x:Array, y:Array, param_dic := {}):
	var function = y_labels.find(id)
	
	if function == -1: #Not found
		Utilities._print_message("The identifier %s does not exist." % id,1)
		return
	
	for param in param_dic.keys():
		match param:
			"label":
				y_labels[function] = param_dic[param]
			"color":
				function_colors[function] = param_dic[param]
	
	x_datas[function] = x
	y_datas[function] = y
	
	calculate_range(id)
	plot()
	update()


func delete_function(id:String):
	var function = y_labels.find(id)
	
	if function == -1: #Not found
		Utilities._print_message("The identifier %s does not exist." % id,1)
		return
	
	y_labels.remove(function)
	x_datas.remove(function)
	y_datas.remove(function)
	y_domain[0].remove(function)
	y_domain[1].remove(function)
	x_domain[0].remove(function)
	x_domain[1].remove(function)
	function_colors.remove(function)
	
	plot()
	update()
	

func generate_identifier():
	#TODO: Check if the identifier generated already exist (given by the user)
	return "f%d" % (y_labels.size() + 1)


func structure_datas(database : Array):
	# @labels_index can be either a column or a row relative to x values
	# @y_values can be either a column or a row relative to y values
	
	#This is done to make sure this arrays are empty on subsecuent calls of this function.
	#This function is called from the "old" methods such as plot_from_array and 
	#for the moment it doesn't clean this variables on clean_variable.
	x_domain = [[], []]
	y_domain = [[], []]
	
	are_values_columns = invert_chart != are_values_columns
	var x_values := []
	
	if are_values_columns:
		var y_values := []
		var y_columns = database[0].size()
		if range(database.size()).has(labels_index): # x column is present
			y_columns -= 1
		else:
			x_values = range(database.size()) #If no x column is given, a generic one is generated
			x_values.push_front("")
		
		for _i in y_columns: #Resize to number of y columns	
			y_values.append([])
		
		for row in database.size():
			var y_column = 0
			for column in database[row].size():
				if column == labels_index:
					var x_data = database[row][column]
					if typeof(x_data) == TYPE_INT  or typeof(x_data) == TYPE_REAL:
						x_values.append(x_data as float)
					else:
						x_values.append(x_data.replace(",", ".") as float)
				else:
					if row != 0:
						var y_data = database[row][column]
						if typeof(y_data) == TYPE_INT or typeof(y_data) == TYPE_REAL:
							y_values[y_column].append(y_data as float)
						else:
							y_values[y_column].append(y_data.replace(",",".") as float)
					else:
						y_labels.append(str(database[row][column]))
					y_column += 1
					
		x_label = str(x_values.pop_front())
		for function in y_values.size():
			y_datas.append(y_values[function])
			x_datas.append(x_values)
	else:
		var database_size = range(database.size())
		if database_size.has(labels_index):
			x_values = database[labels_index]
			x_label = x_values.pop_front() as String
			database_size.erase(labels_index) #Remove x row from the iterator
			
		for row in database_size:
			var y_values = database[row] as Array
			y_labels.append(y_values.pop_front() as String)
			
			for val in y_values.size():
				y_values[val] = y_values[val] as float
			
			y_datas.append(y_values)
			x_datas.append(x_values if not x_values.empty() else range(y_values.size()))

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
	
	if not show_x_values_as_labels:
		x_margin_min = x_range[0]
		var x_margin_max = x_range[1]
		h_dist = x_decim * pow(10.0, calculate_position_significant_figure(x_margin_max - x_margin_min) - 1)

		if x_margin_min < 0 and x_margin_max >= 0:
			calculate_interval_tics(0, x_margin_min, -h_dist, x_labels) #Negative tics
			calculate_interval_tics(0, x_margin_max, h_dist, x_labels, false) #Positive tics
			x_labels.sort()
			x_margin_min = min(x_margin_min, x_labels[0])
		else:
			calculate_interval_tics(x_margin_min, x_margin_max, h_dist, x_labels)
		for i in x_labels.size():
			x_labels[i] = String(x_labels[i])
		x_chors = x_labels
	else:
		for function in y_labels.size():
			for value in x_datas[function]:
				if not x_chors.has(value as String): #Don't append repeated values
					x_chors.append(value as String)


func build_chart():
	var longest_y_tic = 0
	for y_tic in y_chors:
		var length = font.get_string_size(y_tic).x
		if length > longest_y_tic:
			longest_y_tic = length

	OFFSET.x = longest_y_tic + tic_length + 2 * label_displacement
	OFFSET.y = font.get_height() + tic_length + label_displacement
	
	SIZE = get_size() - Vector2(OFFSET.x, 0)
	origin = Vector2(OFFSET.x, SIZE.y - OFFSET.y)


func count_functions():
	functions = y_labels.size()


func calculate_pass():
	# Calculate distance in pixel between 2 consecutive values/datas
	x_pass = (SIZE.x - OFFSET.x) / (x_chors.size() - 1 if x_chors.size() > 1 else x_chors.size())
	y_pass = (origin.y - ChartName.get_rect().size.y * 2) / (y_chors.size() - 1 if y_chors.size() > 1 else y_chors.size())


func calculate_coordinates():
	point_values.clear()
	point_positions.clear()
	
	for _i in y_labels.size():
		point_values.append([])
		point_positions.append([])
	
	for function in y_labels.size():
		for val in x_datas[function].size():
			var value_x = (x_datas[function][val] - x_margin_min) * x_pass / h_dist if h_dist else 0 \
					if not show_x_values_as_labels else x_chors.find(String(x_datas[function][val])) * x_pass
			var value_y = (y_datas[function][val] - y_margin_min) * y_pass / v_dist if v_dist else 0
	
			point_values[function].append([x_datas[function][val], y_datas[function][val]])
			point_positions[function].append(Vector2(value_x + origin.x, origin.y - value_y))



func draw_grid():
	# ascisse
	for p in x_chors.size():
		var point : Vector2 = origin + Vector2(p * x_pass, 0)
		var size_text : Vector2 = font.get_string_size(x_chors[p])
		# v grid
		draw_line(point, point - Vector2(0, SIZE.y - OFFSET.y), v_lines_color, grid_lines_width, true)
		# ascisse
		draw_line(point + Vector2(0, tic_length), point, v_lines_color, grid_lines_width, true)
		draw_string(font, point + Vector2(-size_text.x / 2, size_text.y + tic_length),
				x_chors[p], font_color)
	
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


func draw_chart_outlines():
	draw_line(origin, SIZE-Vector2(0, OFFSET.y), box_color, 1, true)
	draw_line(origin, Vector2(OFFSET.x, 0), box_color, 1, true)
	draw_line(Vector2(OFFSET.x, 0), Vector2(SIZE.x, 0), box_color, 1, true)
	draw_line(Vector2(SIZE.x, 0), SIZE - Vector2(0, OFFSET.y), box_color, 1, true)


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
