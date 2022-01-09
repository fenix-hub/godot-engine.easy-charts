tool
extends ScatterChartBase
class_name ColumnChart

"""
[ColumnChart] - General purpose node for Column Charts

A bar chart or bar graph is a chart or graph that presents categorical data with 
rectangular bars with heights or lengths proportional to the values that they represent. 
The bars can be plotted vertically or horizontally. A vertical bar chart is sometimes 
called a column chart.
A bar graph shows comparisons among discrete categories. One axis of the chart shows 
the specific categories being compared, and the other axis represents a measured value. 
Some bar graphs present bars clustered in groups of more than one, showing the 
values of more than one measured variable.

/ source : Wikipedia /
"""

# ---------------------

func build_property_list():
	.build_property_list()
	
	property_list.append(
	{
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "1,20,0.5",
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Properties/column_width",
			"type": TYPE_REAL
	})
	property_list.append(
	{
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0,10,0.5",
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Properties/column_gap",
			"type": TYPE_REAL
	})


func _get_property_list():
	property_list[0].name = "ColumnChart"
	return property_list


# @Override
func calculate_coordinates():
	point_values.clear()
	point_positions.clear()
	
	for _i in y_labels.size():
		point_values.append([])
		point_positions.append([])
	
	for function in y_labels.size():
		for val in x_datas[function].size():
			var value_x: float = (int(x_datas[function][val]) - x_margin_min) * x_pass / h_dist if h_dist else \
				x_chors.find(String(x_datas[function][val])) * x_pass
			var value_y: float = (y_datas[function][val] - y_margin_min) * y_pass / v_dist if v_dist else 0
			var column_offset: float = column_width/2 + (column_width + column_gap)*function - (column_width + column_gap)*functions/2
			point_values[function].append([x_datas[function][val], y_datas[function][val]])
			point_positions[function].append(Vector2(value_x + origin.x + column_offset, origin.y - value_y))

func _draw():
	draw_grid()
	draw_chart_outlines()
	if show_points:
		draw_points()
	draw_columns()
	draw_treshold()

func draw_columns():
	for function in point_values.size():
		for function_point in range(0, point_values[function].size()):
			draw_line(
				Vector2(point_positions[function][function_point].x, origin.y),
				point_positions[function][function_point],
				function_colors[function],
				column_width, 
				false)
#            draw_string(font, Vector2(point_positions[function][function_point].x, origin.y+10), y_labels[function_point], font_color)

