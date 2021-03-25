tool
extends ScatterChartBase
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

var show_points := true
var function_line_width : int = 2


func build_property_list():
	.build_property_list()
	
	property_list.append(
	{
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Display/show_points",
		"type": TYPE_BOOL
	})
	
	#Find first element of Chart Display
	var position
	for i in property_list.size():
		if property_list[i]["name"].find("Chart_Style") != -1: #Found
			position = i
			break
		
	property_list.insert(position + 2, #I want it to be below point shape and function colors
	{
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "1, 100, 1",
		"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
		"name": "Chart_Style/function_line_width",
		"type": TYPE_INT
	})


func _get_property_list():
	property_list[0].name = "LineChart"
	return property_list


func _get(property):
	match property:
		"Chart_Display/show_points":
			return show_points
		"Chart_Style/function_line_width":
			return function_line_width


func _set(property, value):
	match property:
		"Chart_Display/show_points":
			show_points = value
			return true
		"Chart_Style/function_line_width":
			function_line_width = value
			return true


func _draw():
	clear_points()
	draw_grid()
	draw_chart_outlines()
	if show_points:
		draw_points()
	draw_lines()
	draw_treshold()


func draw_lines():
	for function in point_values.size():
		for function_point in range(1, point_values[function].size()):
			draw_line(
				point_positions[function][function_point - 1],
				point_positions[function][function_point],
				function_colors[function],
				function_line_width, 
				false)
