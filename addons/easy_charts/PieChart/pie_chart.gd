tool
extends Chart
class_name PieChart

var should_draw : bool = false
var area_angles : Array 
var slices : Array
var areas : Array
var areas_interacted : Array

class CustomSorter:
	static func sort_ascending(a,b):
		if a[1] < b[1]:
			return true
		return false

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
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Properties/show_x_values_as_labels",
			"type": TYPE_BOOL
		},

		# Chart Style
		{
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
			"name": "Chart_Style/function_colors",
			"type": TYPE_COLOR_ARRAY
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

		# Chart Modifiers
		{
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0,360",
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
				"name": "Chart_Modifiers/rotation",
				"type": TYPE_REAL
		},
	]



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func plot_placeholder() -> void:
	data = [
		["United States",46],
		["Great Britain",27],
		["China",26],
		["Russia",19],
		["Germany",17]
	]
	
	function_colors = [
		Color.red,
		Color.white,
		Color.yellow,
		Color.green,
		Color.blue
	]
	plot_from_array(data)

func structure_datas(database: Array):
	# @labels_index can be either a column or a row relative to x values
	clean_variables()
	are_values_columns = invert_chart != are_values_columns
	if are_values_columns:
		for row in database.size():
			var t_vals: Array
			for column in database[row].size():
				if column == labels_index:
					var x_data = database[row][column]
					if x_data.is_valid_float() or x_data.is_valid_integer():
						x_datas.append(x_data as float)
					else:
						x_datas.append(x_data.replace(",", ".") as float)
				else:
					if row != 0:
						var y_data = database[row][column]
						if y_data.is_valid_float() or y_data.is_valid_integer():
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


func build_chart():
	SIZE = get_size()
	origin = SIZE/2
	radius = (SIZE.y/2 - 20) if SIZE.y < SIZE.x else (SIZE.x/2 - 20)

func calculate_pass():
	var tot : float
	for y_data in y_datas: tot+=y_data[0]
	x_pass = 360/tot

func calculate_coordinates():
	area_angles.clear()
	slices.clear()
	areas.clear()
	var from : float = 0.0
	var to : float = y_datas[0][0]*x_pass
	area_angles.append([from,to])
	for info in range(y_datas.size()):
		slices.append(Slice.new(y_labels[info], str(y_datas[info][0]), from, to, x_label+" : "+x_datas[0], function_colors[info]))
		areas.append(calculate_circle_arc_polygon(origin, radius, from + rotation, to + rotation, function_colors[info]))
		from = to
		to = (y_datas[info+1][0]*x_pass + from) if info < y_datas.size()-1 else (360)
		area_angles.append([from, to])
	
	create_legend()

func calculate_circle_arc_polygon(center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color) -> PoolVector2Array:
	var nb_points : int = 32
	var points_arc : PoolVector2Array = PoolVector2Array()
#	var chord_angle : float = ((angle_to - angle_from)/2)+angle_from
#	angle_from += 0.2
#	angle_to -= 0.2
#	var displacement : Vector2 = Vector2(cos(deg2rad(chord_angle)), sin(deg2rad(chord_angle-180))).normalized()*10
#	print(displacement)
#	center += displacement
#	radius+=displacement.length()
	points_arc.push_back(center)
	var colors : PoolColorArray = PoolColorArray([color])
	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	return points_arc

func _draw():
	_draw_areas()
	
	if mouse_on_slice:
		_draw_arc(area_angles[mouse_on_area], mouse_on_area)
		mouse_on_slice = false

func _draw_arc(arc : Array, index : int):
	var temp_color : Color = function_colors[index]
	temp_color.a = 0.7
	draw_arc(origin, radius + 6, deg2rad(arc[0]-90 + rotation), deg2rad(arc[1]-90 + rotation), 32, temp_color, 4)

func _draw_areas():
	for area_idx in range(areas.size()):
		draw_polygon(areas[area_idx], [function_colors[area_idx]])

var mouse_on_area : int
var mouse_on_slice : bool = false

func _gui_input(event : InputEvent):
	if event is InputEventMouseMotion:
		for area_idx in range(areas.size()):
			if Geometry.is_point_in_polygon(event.global_position - get_global_transform().origin, areas[area_idx]):
				mouse_on_slice = true
				mouse_on_area = area_idx
				show_slice_data(slices[area_idx])
				update()
		
		if not mouse_on_slice:
			mouse_on_area = -1
			mouse_on_slice = false
			hide_data()
			update()
