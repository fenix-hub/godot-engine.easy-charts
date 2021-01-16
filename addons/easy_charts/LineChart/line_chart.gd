tool
extends Chart
class_name LineChart

# [Linechart] - General purpose node for Line Charts
# A line chart or line plot or line graph or curve chart is a type of chart which
# displays information as a series of data points called 'markers'
# connected by straight line segments.
# It is a basic type of chart common in many fields. It is similar to a scatter plot
# except that the measurement points are ordered (typically by their x-axis value)
# and joined with straight line segments.
# A line chart is often used to visualize a trend in data over intervals of time -
# a time series - thus the line is often drawn chronologically.
# In these cases they are known as run charts.
# Source: Wikipedia


func _get_property_list():
	return [
		# Chart Properties
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_CATEGORY,
			"name": "LineChart",
			"type": TYPE_STRING
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Properties/are_values_columns",
			"type": TYPE_BOOL
		},
		{
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "-1,100,1",
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Properties/labels_index",
			"type": TYPE_INT
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Properties/show_x_values_as_labels",
			"type": TYPE_BOOL
		},

		# Chart Display
		{
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.1,10",
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Display/x_decim",
			"type": TYPE_REAL
		},
		{
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.001,1,0.001",
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Display/y_decim",
			"type": TYPE_REAL
		},

		# Chart Style
		{
			"hint": 24,
			"hint_string":
			(
				"%d/%d:%s"
				% [TYPE_INT, PROPERTY_HINT_ENUM, PoolStringArray(PointShapes.keys()).join(",")]
			),
			"name": "Chart_Style/points_shape",
			"type": TYPE_ARRAY,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Style/function_colors",
			"type": TYPE_COLOR_ARRAY
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Style/box_color",
			"type": TYPE_COLOR
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Style/v_lines_color",
			"type": TYPE_COLOR
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Style/h_lines_color",
			"type": TYPE_COLOR
		},
		{
			"class_name": "Font",
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Font",
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Style/font",
			"type": TYPE_OBJECT
		},
		{
			"class_name": "Font",
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Font",
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Style/bold_font",
			"type": TYPE_OBJECT
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Style/font_color",
			"type": TYPE_COLOR
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Style/use_template",
			"type": TYPE_BOOL
		},
		{
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(Utilities.templates.keys()).join(","),
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Style/template",
			"type": TYPE_INT
		},

		# Chart Modifiers
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Modifiers/treshold",
			"type": TYPE_VECTOR2
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Modifiers/only_disp_values",
			"type": TYPE_VECTOR2
		},
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Modifiers/invert_chart",
			"type": TYPE_BOOL
		},
	]


func structure_datas(database: Array):
	# @labels_index can be either a column or a row relative to x values
	are_values_columns = (invert_chart != are_values_columns)
	if are_values_columns:
		for row in database.size():
			var t_vals: Array
			for column in database[row].size():
				if column == labels_index:
					var x_data = database[row][column]
					if typeof(x_data) == TYPE_INT  or typeof(x_data) == TYPE_REAL:
						x_datas.append(x_data as float)
					else:
						x_datas.append(x_data)
				else:
					if row != 0:
						var y_data = database[row][column]
						if typeof(y_data) == TYPE_INT  or typeof(y_data) == TYPE_REAL:
							t_vals.append(y_data as float)
						else:
							t_vals.append(y_data.replace(",", ".") as float)
					else:
						y_labels.append(str(database[row][column]))
			if not t_vals.empty():
				y_datas.append(t_vals)
		x_label = str(x_datas.pop_front())
	else:
		for row in database.size():
			if row == labels_index:
				x_datas = (database[row])
				x_label = x_datas.pop_front() as String
			else:
				var values = database[row] as Array
				y_labels.append(values.pop_front() as String)
				y_datas.append(values)
		for data in y_datas:
			for value in data.size():
				data[value] = data[value] as float
	
	# draw y labels
	var to_order: Array
	var to_order_min: Array
	for cluster in y_datas.size():
		# define x_chors and y_chors
		var ordered_cluster = y_datas[cluster].duplicate() as Array
		ordered_cluster.sort()
		var margin_max = ordered_cluster[ordered_cluster.size() - 1]
		var margin_min = ordered_cluster[0]
		to_order.append(margin_max)
		to_order_min.append(margin_min)

	to_order.sort()
	to_order_min.sort()
	var margin = to_order.pop_back()
	if not origin_at_zero:
		y_margin_min = to_order_min.pop_front()
	v_dist = y_decim * pow(10.0, str(margin).length()-1) #* pow(10.0, (str(margin).length() - 2 if typeof(margin) == TYPE_INT else str(margin).length() - str(y_decim).length() ))
	var multi = 0
	var p = (v_dist * multi) + ((y_margin_min) if not origin_at_zero else 0)
	y_chors.append(p as String)
	while p < margin:
		multi += 1
		p = (v_dist * multi) + ((y_margin_min) if not origin_at_zero else 0)
		y_chors.append(p as String)
	OFFSET.x = (str(margin).length()) * font_size
	OFFSET.y = (font_size * 2) - 4

func build_chart():
	SIZE = get_size() - Vector2(OFFSET.x,0)
	origin = Vector2(OFFSET.x, SIZE.y - OFFSET.y)


func calculate_pass():
	x_chors = x_datas.duplicate(true) as PoolStringArray
	
	
	# calculate distance in pixel between 2 consecutive values/datas
	x_pass = (SIZE.x - OFFSET.x) / (x_chors.size()-1 if x_chors.size()>1 else x_chors.size() )
	y_pass = (origin.y - ChartName.get_rect().size.y*2) / (y_chors.size() - 1)


func calculate_coordinates():
	x_coordinates.clear()
	y_coordinates.clear()
	point_values.clear()
	point_positions.clear()
	
	for cluster in y_datas:
		var single_coordinates: Array
		for value in cluster.size():
			if origin_at_zero:
				single_coordinates.append((cluster[value] * y_pass) / v_dist)
			else:
				single_coordinates.append((cluster[value] - y_margin_min) * y_pass / v_dist)
		y_coordinates.append(single_coordinates)
	
	for x in x_datas.size():
		x_coordinates.append(x_pass * x)

	for f in range(0,functions):
		point_values.append([])
		point_positions.append([])

	for cluster in y_coordinates.size():
		for y in y_coordinates[cluster].size():
			if are_values_columns:
				point_values[y].append([x_datas[cluster], y_datas[cluster][y]])
				point_positions[y].append(Vector2(
						x_coordinates[cluster] + origin.x, origin.y - y_coordinates[cluster][y]))
			else:
				point_values[cluster].append([x_datas[y], y_datas[cluster][y]])
				point_positions[cluster].append(Vector2(
						x_coordinates[y] + origin.x,
						origin.y - y_coordinates[cluster][y]))

func _draw():
	clear_points()
	draw_grid()
	draw_chart_outlines()
	
	var defined_colors: bool = false
	if function_colors.size():
		defined_colors = true
	
	if Points.get_child_count() > 0 :
		for point in Points.get_children():
			point.queue_free()
	
	for _function in point_values.size():
		for function_point in point_values[_function].size():
			var point: Point = point_node.instance()
			point.connect("_point_pressed", self, "point_pressed")
			point.connect("_mouse_entered", self, "show_data")
			point.connect("_mouse_exited", self, "hide_data")
			point.create_point(points_shape[_function],function_colors[_function],Color.white,point_positions[_function][function_point],point.format_value(point_values[_function][function_point], false, false),y_labels[_function] as String)

			Points.add_child(point)
			if function_point > 0:
				draw_line(
						point_positions[_function][function_point - 1],
						point_positions[_function][function_point],
						function_colors[_function],
						2,
						false)
	draw_treshold()

func draw_grid():
	# ascisse
	for p in x_chors.size():
		var point: Vector2 = origin + Vector2((p) * x_pass, 0)
		# v grid
		draw_line(point, point - Vector2(0, SIZE.y - OFFSET.y*2), v_lines_color, 0.2, true)
		# ascisse
		draw_line(point - Vector2(0, 5), point, v_lines_color, 1, true)
		if show_x_values_as_labels : pass 
		else: continue
		draw_string(
				font,
				point + Vector2(-const_width / 2 * x_chors[p].length(), font_size + const_height),
				x_chors[p],
				font_color)
	
	if not show_x_values_as_labels : 
		draw_string(
				font,
				Vector2((SIZE.x - origin.x)/2 + ((x_label.length() * font_size) / 2), SIZE.y - font_size/2),
				x_label,
				font_color)
	
	# ordinate
	for p in y_chors.size():
		var point: Vector2 = origin - Vector2(0, (p) * y_pass)
		# h grid
		draw_line(point, point + Vector2(SIZE.x - OFFSET.x, 0), h_lines_color, 0.2, true)
		# ordinate
		draw_line(point, point + Vector2(5, 0), h_lines_color, 1, true)
		draw_string(
				font,
				point - Vector2(y_chors[p].length() * const_width + font_size, -const_height),
				y_chors[p],
				font_color)

func draw_chart_outlines():
	draw_line(origin, SIZE - Vector2(0, OFFSET.y), box_color, 1.2, true)
	draw_line(origin, Vector2(OFFSET.x, OFFSET.y), box_color, 1.2, true)
	draw_line(Vector2(OFFSET.x, OFFSET.y), Vector2(SIZE.x, OFFSET.y), box_color, 1.2, true)
	draw_line(Vector2(SIZE.x, OFFSET.y), SIZE - Vector2(0, OFFSET.y), box_color, 1.2, true)

func draw_treshold():
	if v_dist != 0:
		treshold_draw = Vector2((treshold.x * x_pass) + origin.x ,origin.y - ((treshold.y * y_pass)/v_dist))
		if treshold.y != 0:
			draw_line(Vector2(origin.x, treshold_draw.y), Vector2(SIZE.x, treshold_draw.y), Color.red, 0.4, true)
		if treshold.x != 0:
			draw_line(Vector2(treshold_draw.x, 0), Vector2(treshold_draw.x, SIZE.y - OFFSET.y), Color.red, 0.4, true)
