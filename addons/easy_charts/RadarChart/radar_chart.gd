tool
extends Chart
class_name RadarChart

"""
[RadarChart] - General purpose node for Radar Charts
A radar chart is a graphical method of displaying multivariate data in the form 
of a two-dimensional chart of three or more quantitative variables represented on axes 
starting from the same point. The relative position and angle of the axes is typically 
uninformative, but various heuristics, such as algorithms that plot data as the maximal 
total area, can be applied to sort the variables (axes) into relative positions that reveal 
distinct correlations, trade-offs, and a multitude of other comparative measures.

/ source : Wikipedia /
"""

func _get_property_list():
		return [
				# Chart Properties
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
						"hint": PROPERTY_HINT_RANGE,
						"hint_string": "-1,100,1",
						"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
						"name": "Chart_Properties/function_names_index",
						"type": TYPE_INT
				},
				{
						"hint": PROPERTY_HINT_NONE,
						"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
						"name": "Chart_Properties/use_height_as_radius",
						"type": TYPE_BOOL
				},
				{
						"hint": PROPERTY_HINT_RANGE,
						"hint_string": "0,2000",
						"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
						"name": "Chart_Properties/radius",
						"type": TYPE_REAL
				},
				
				# Chart Display
				{
						"hint": PROPERTY_HINT_RANGE,
						"hint_string": "0.1,100",
						"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
						"name": "Chart_Display/full_scale",
						"type": TYPE_REAL
				},
				
				# Chart Style
				{ 
						"hint": 24, 
						"hint_string": "%d/%d:%s"%[TYPE_INT, PROPERTY_HINT_ENUM,
						PoolStringArray(PointShapes.keys()).join(",")],
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
						"name": "Chart_Style/outline_color",
						"type": TYPE_COLOR
				},
				{
						"hint": PROPERTY_HINT_NONE,
						"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
						"name": "Chart_Style/grid_color",
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
						"hint": PROPERTY_HINT_ENUM,
						"hint_string": PoolStringArray(Utilities.templates.keys()).join(","),
						"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
						"name": "Chart_Style/template",
						"type": TYPE_INT
				},
				{
						"hint": PROPERTY_HINT_RANGE,
						"hint_string": "0,360",
						"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
						"name": "Chart_Modifiers/rotation",
						"type": TYPE_REAL
				},
		]

func structure_datas(database : Array):
	# @x_values_index can be either a column or a row relative to x values
	# @y_values can be either a column or a row relative to y values
	are_values_columns = invert_chart != are_values_columns
	match are_values_columns:
		true:
			for row in database.size():
				var t_row : Array = []
				for column in database[row].size():
					if row == labels_index:
						if column == function_names_index:
							pass
						else:
							x_labels.append(database[row][column])
					else:
						if column == function_names_index:
							y_labels.append(database[row][column])
						else:
							if typeof(database[row][column]) == TYPE_INT or typeof(database[row][column]) == TYPE_REAL:
								t_row.append(database[row][column] as float)
							else:
								t_row.append(database[row][column].replace(",", ".") as float)
				if not t_row.empty():
					x_datas.append(t_row)
		false:
			for row in database.size():
				if row == function_names_index:
					y_labels = database[row] as PoolStringArray
				
				var x_temp_datas : PoolRealArray = []
				for column in database[row].size():
					if column == labels_index:
						x_labels.append(database[row][column] as String)
					else:
						x_temp_datas.append(database[row][column] as float)
					x_datas.append(x_temp_datas)
	
	
	if labels_index == -1 :
			for data in x_datas[0].size():
					x_labels.append("Element %s" % data)
	
	if function_names_index == -1 :
			for data in x_datas.size():
					y_labels.append("Function %s" % data)

func build_chart():
	SIZE = get_size()
	origin = OFFSET + SIZE/2

var radar_polygon : Array

func calculate_pass() : 
	var ordered_max : Array
	for data in x_datas :
		var ordered_data : Array = data.duplicate()
		ordered_data.sort()
		ordered_max.append(ordered_data.pop_back())
	ordered_max.sort()
	var max_value : float = ordered_max.pop_back()
	var dist = full_scale * pow(10.0,str(max_value).length()-2)
	var multi = 0
	var value = dist * multi
	x_chors.append(value as String)
	while value < max_value:
		multi+=1
		value = dist * multi
		x_chors.append(value as String)

func calculate_coordinates():
	for chor in x_chors.size():
		var inner_polyline : PoolVector2Array
		var scalar_factor : float = (x_chors[chor] as float/x_chors.back() as float)
		for function in functions:
			var angle : float =  ((2 * PI * function) / functions) - PI /2 + deg2rad(rotation)
			var x_coordinate : float = (radius if (not use_height_as_radius and radius<SIZE.y/2) else SIZE.y/2) * scalar_factor * cos(angle) + origin.x
			var y_coordinate : float = (radius if (not use_height_as_radius and radius<SIZE.y/2) else SIZE.y/2) * scalar_factor * sin(angle) + origin.y
			inner_polyline.append(Vector2(x_coordinate, y_coordinate))
		inner_polyline.append(inner_polyline[0])
		radar_polygon.append(inner_polyline)
	
	for datas in x_datas:
		var function_positions : PoolVector2Array
		var function_values : Array
		for data in datas.size():
			var scalar_factor : float = datas[data] /( x_chors.back() as float)
			var angle : float =  ((2 * PI * data) / datas.size()) - PI/2 + deg2rad(rotation)
			var x_coordinate : float = (radius if (not use_height_as_radius and radius<SIZE.y/2) else SIZE.y/2) * scalar_factor * cos(angle) + origin.x
			var y_coordinate : float = (radius if (not use_height_as_radius and radius<SIZE.y/2) else SIZE.y/2) * scalar_factor * sin(angle) + origin.y
			function_positions.append(Vector2(x_coordinate,y_coordinate))
			function_values.append([x_labels[data], datas[data]])
		function_positions.append(function_positions[0])
		point_positions.append(function_positions)
		point_values.append(function_values)

func _draw():
		if Engine.editor_hint:
				return
		
		clear_points()
		draw_grid()
		
		for function in point_positions.size():
				var function_color : Color = function_colors[function]
				draw_polygon(point_positions[function], [Color(function_color.r, function_color.g, function_color.b, 0.2)],[],null,null,true)
				draw_polyline(point_positions[function], function_color, 2,true)
		
		for _function in point_values.size():
				var PointContainer : Control = Control.new()
				Points.add_child(PointContainer)
				
				for function_point in point_values[_function].size():
						var point : Point = point_node.instance()
						point.connect("_point_pressed",self,"point_pressed")
						point.connect("_mouse_entered",self,"show_data")
						point.connect("_mouse_exited",self,"hide_data")
						
						point.create_point(points_shape[_function], function_colors[_function], 
						Color.white, point_positions[_function][function_point], 
						point.format_value(point_values[_function][function_point], false, false),
						y_labels[_function])
#			str("Function %s"%_function))
						
						PointContainer.add_child(point)

func draw_grid():
		for polyline in radar_polygon:
				draw_polyline(polyline, grid_color, 1, true)
				var text : String = x_chors[radar_polygon.find(polyline)] as String
				draw_string(font, polyline[0] - Vector2(font.get_string_size(text).x/2,-5), text, font_color)
		
		if not radar_polygon.empty():
				draw_polyline(radar_polygon[radar_polygon.size()-1], outline_color, 1, true)
		
		for label in x_labels.size():
				var point_array : PoolVector2Array = radar_polygon[radar_polygon.size()-1]
				draw_line(origin, point_array[label], grid_color, 1, true)
				
				if point_array[label].x != origin.x:
						draw_string(font, point_array[label] - (Vector2(font.get_string_size(x_labels[label]).x+10,(5 if point_array[label].y <= origin.y else -10)) if point_array[label].x <= origin.x else - Vector2(10,(-5 if point_array[label].y <= origin.y else 10))), x_labels[label], font_color)
				else:
						draw_string(font, point_array[label] - (Vector2(font.get_string_size(x_labels[label]).x/2, 10) if point_array[label].y < origin.x else - Vector2(font.get_string_size(x_labels[label]).x/2, 5)), x_labels[label], font_color)

func create_legend():
		pass
#	legend.clear()
#	for function in functions:
#		var function_legend = FunctionLegend.instance()
#		var f_name : String = x_labels[function]
#		var legend_font : Font
#		if font != null:
#			legend_font = font
#		if bold_font != null:
#			legend_font = bold_font
#		function_legend.create_legend(f_name,function_colors[function],bold_font,font_color)
#		legend.append(function_legend)

func count_functions():
		if x_labels.size():
				functions = x_labels.size()
