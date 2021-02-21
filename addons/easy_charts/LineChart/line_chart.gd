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


func _get_property_list():
 property_list[0].name = "LineChart"
 return property_list


func _draw():
	clear_points()
	draw_grid()
	draw_chart_outlines()
	draw_points()
	draw_lines()
	draw_treshold()


func draw_lines():
	var _function = 0
	for PointContainer in Points.get_children(): #Each function is stored in a different PointContainer
		for function_point in range(1, PointContainer.get_children().size()):
			draw_line(
					point_positions[_function][function_point - 1],
					point_positions[_function][function_point],
					function_colors[_function],
					2,
					false)
		_function += 1
