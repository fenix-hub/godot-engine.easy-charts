tool
extends ScatterChartBase
class_name ScatterChart

"""
[ScatterChart] - General purpose node for Scatter Charts

A scatter plot (also called a scatterplot, scatter graph, scatter chart, scattergram, or scatter diagram)
 is a type of plot or mathematical diagram using Cartesian coordinates to display values for typically two variables 
for a set of data. If the points are coded (color/shape/size), one additional variable can be displayed. 
The data are displayed as a collection of points, each having the value of one variable determining the position on 
the horizontal axis and the value of the other variable determining the position on the vertical axis.

/ source : Wikipedia /
"""

# ---------------------


func _get_property_list():
 property_list[0].name = "ScatterChart"
 return property_list


func _draw():
	clear_points()
	draw_grid()
	draw_chart_outlines()
	draw_points()
	draw_treshold()
