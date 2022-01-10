extends Control
class_name Chart

# Classes
enum TYPES { Line, Bar, Scatter, Radar, Pie }

# Signals ..................................
signal chart_plotted(chart) # emit when a chart is plotted (static) or updated (dynamic)
signal point_pressed(point)

# Onready Vars ............................
onready var data_tooltip = $CanvasLayer/DataTooltip
onready var Points = $Points
onready var Legend = $Legend
onready var ChartName : Label = $ChartName

# Scenes and Reosurces ......................
var point_node : PackedScene = preload("../../components/point/point.tscn")
var legend_element : PackedScene = preload("../../containers/legend/function_legend.tscn")

# Shared Variables .........................
var SIZE : Vector2 = Vector2()
var OFFSET : Vector2 = Vector2(0,0)
var origin : Vector2

var font_size : float = 16
var const_height : float = font_size/2*font_size/20
var const_width : float = font_size/2

# actual distance between x and y values 
var x_pass : float
var y_pass : float

# vertical distance between y consecutive points used for intervals
var v_dist : float
var h_dist : float

# define values on x an y axis
var x_chors : Array
var y_chors : Array

# actual coordinates of points (in pixel)
var x_coordinates : Array
var y_coordinates : Array

# data contained in file
var data : Array
# If using a Dataframe
var dataframe: DataFrame

# amount of functions to represent
var functions : int = 0

# database values
var x_datas : Array
var y_datas : Array

# labels displayed on chart
var x_label : String

var x_labels : Array
var y_labels : Array

var x_margin_min : float = 0
var y_margin_min : float = 0

# actual values of point, from the database
var point_values : Array

# actual position of points in pixel
var point_positions : Array

var legend : Array setget set_legend,get_legend

# ................... Export Shared Variables ..................
export (String) var chart_name : String = "" setget set_chart_name
export (String, FILE, "*.txt, *.csv, *.res") var source : String = "" setget set_source
export (String) var delimiter : String = ";" setget set_delimiter

var origin_at_zero : bool = false 			setget set_origin_at_zero#, get_origin_at_zero
var are_values_columns : bool = true   	setget set_are_values_columns#, get_are_values_columns

var labels_index : int = 0					setget set_labels_index#, get_labels_index
var function_names_index : int = 0			setget set_function_names_index#, get_function_names_index

# for radar
var use_height_as_radius : bool = false		setget set_use_height_as_radius
var radius : float = 150.0					setget _set_radius,get_radius

# for columns
var function_line_width : int = 2

var column_width : float = 10				setget set_column_width
var column_gap : float = 2					setget set_column_gap

# Calculations of decim and its relation with number of tics: https://www.desmos.com/calculator/jeiceaswiy
var full_scale : float = 1.0				setget set_full_scale
var x_decim : float = 1.0					setget set_x_decim
var y_decim : float = 1.0					setget set_y_decim

var points_shape : Array = [Point.SHAPES.Dot]	setget set_points_shape
var function_colors = [Color("#1e1e1e")]		setget set_function_colors
var outline_color : Color = Color("#1e1e1e")	setget set_outline_color
var box_color : Color = Color("#1e1e1e")		setget set_box_color
var grid_lines_width : int = 1					setget set_grid_lines_width
var v_lines_color : Color = Color("#cacaca")	setget set_v_lines_color
var h_lines_color : Color = Color("#cacaca")	setget set_h_lines_color
var grid_color : Color = Color("#1e1e1e")		setget set_grid_color
var font : Font									setget set_font
var bold_font : Font							setget set_bold_font
var font_color : Color = Color("#1e1e1e")		setget set_font_color

var show_points := true

var use_template : bool = true		setget set_use_template
var template : int = 0		setget set_template

# modifiers
var rotation : float = 0						setget set_rotation
var invert_chart : bool = false					setget set_invert_chart

# Only disp a certain range of values:
# (x , 0) -> Only disp first 'x' values
# (0 , y) -> Only disp last 'y' values
# (x , y) -> Only disp values in range [x, y]
# (0 , 0) -> Disp all values (full range)
var only_disp_values : Vector2 = Vector2(0,0) setget set_only_disp_values

# A vector representing limit values (both on x and y axis) you want to stay over or below
# The treshold value is always relative to your dataset values
# ex. if your dataset is [ [100,100], [300,300] ] a proper treshold would be (200,200)
var treshold : Vector2 setget set_treshold

# A vector representing @treshold coordinates in its relative chart
# only used to draw treshold values
var treshold_draw : Vector2

# Custom parameters for plot display
var tic_length : int = 5	setget set_tic_length # Length of the bar indicating a tic
var label_displacement : int = 4 setget set_label_displacement # Separation between the label and both the axis and the edge border

var property_list: Array = []



# ..........................................



# !! API v2
static func instance(chart_type : int):
	var chart_t : Array = ECUtilities.get_chart_type(chart_type)
	var chart : String = "res://addons/easy_charts/control_charts/%s/%s.tscn" % [chart_t[0], chart_t[1]]
	return load(chart).instance()

# .......................... Properties Manager ....................................
func _get(property):
	match property:
		"Chart_Properties/origin_at_zero":
			return origin_at_zero
		"Chart_Properties/are_values_columns":
			return are_values_columns
		"Chart_Properties/labels_index":
			return labels_index
		"Chart_Properties/function_names_index":
			return function_names_index
		"Chart_Properties/use_height_as_radius":
			return use_height_as_radius
		"Chart_Properties/radius":
			return radius
		"Chart_Properties/column_width":
			return column_width
		"Chart_Properties/column_gap":
			return column_gap
		"Chart_Style/function_line_width":
			return function_line_width

		
		"Chart_Display/full_scale":
			return full_scale
		"Chart_Display/x_decim":
			return x_decim
		"Chart_Display/y_decim":
			return y_decim
		
		"Chart_Style/points_shape":
			return points_shape
		"Chart_Style/function_colors":
			return function_colors
		"Chart_Style/template":
			return template
		"Chart_Style/use_template":
			return use_template
		"Chart_Style/outline_color":
			return outline_color
		"Chart_Style/grid_color":
			return grid_color
		"Chart_Style/box_color":
			return box_color
		"Chart_Style/grid_lines_width":
			return grid_lines_width
		"Chart_Style/v_lines_color":
			return v_lines_color
		"Chart_Style/h_lines_color":
			return h_lines_color
		"Chart_Style/font":
			return font
		"Chart_Style/bold_font":
			return bold_font
		"Chart_Style/font_color":
			return font_color
		
		"Chart_Modifiers/treshold":
			return treshold
		"Chart_Modifiers/only_disp_values":
			return only_disp_values
		"Chart_Modifiers/rotation":
			return rotation
		"Chart_Modifiers/invert_chart":
			return invert_chart

func _set(property, value):
	match property:
		"Chart_Properties/origin_at_zero":
			origin_at_zero = value
			return true
		"Chart_Properties/are_values_columns":
			are_values_columns = value
			return true
		"Chart_Properties/labels_index":
			labels_index = value
			return true
		"Chart_Properties/function_names_index":
			function_names_index = value
			return true
		"Chart_Properties/use_height_as_radius":
			use_height_as_radius = value
			return true
		"Chart_Properties/radius":
			radius = value
			return true
		"Chart_Properties/column_width":
			column_width = value
			return true
		"Chart_Properties/column_gap":
			column_gap = value
			return true
		"Chart_Style/function_line_width":
			function_line_width = value
			return true
		
		"Chart_Display/full_scale":
			full_scale = value
			return true
		"Chart_Display/x_decim":
			x_decim = value
			return true
		"Chart_Display/y_decim":
			y_decim = value
			return true
		
		"Chart_Style/points_shape":
			points_shape = value
			return true
		"Chart_Style/function_colors":
			function_colors = value
			return true
		"Chart_Style/use_template":
			use_template = value
			return true
		"Chart_Style/template":
			template = value
			apply_template(template)
			return true
		"Chart_Style/outline_color":
			outline_color = value
			return true
		"Chart_Style/grid_color":
			grid_color = value
			return true
		"Chart_Style/box_color":
			box_color = value
			return true
		"Chart_Style/grid_lines_width":
			grid_lines_width = value
			return true
		"Chart_Style/v_lines_color":
			v_lines_color = value
			return true
		"Chart_Style/h_lines_color":
			h_lines_color = value
			return true
		"Chart_Style/font":
			font = value
			return true
		"Chart_Style/bold_font":
			bold_font = value
			return true
		"Chart_Style/font_color":
			font_color = value
#			apply_template(template)
			return true
		
		"Chart_Modifiers/treshold":
			treshold = value
			return true
		"Chart_Modifiers/only_disp_values":
			only_disp_values = value
			return true
		"Chart_Modifiers/rotation":
			rotation = value
			return true
		"Chart_Modifiers/invert_chart":
			invert_chart = value
			return true

func _init():
	build_property_list()

func _ready():
	load_font()

# .......................... Shared Functions and virtuals ........................

# Structure and Display a new plot if a dataset source is given
# both through APIs or from Inspector
func plot(_dataset: Array = read_data(source, delimiter)) -> void:
	clean_variables()
	clean_points()
	data_tooltip.hide()
	
	if _dataset.empty():
		ECUtilities._print_message("Can't plot a chart with an empty Array.",1)
		return
	
	are_values_columns = invert_chart != are_values_columns
	
	# Read the dataset in the proper way 
	var database : Array = _dataset \
	if not are_values_columns \
	else MatrixGenerator.transpose(Matrix.new(_dataset)).to_array()
	
	data = slice_data(database)
	structure_data(data)
	compute_display()
	display_plot()
	emit_signal("chart_plotted",self)
	if not is_connected("item_rect_changed", self, "redraw_plot"): connect("item_rect_changed", self, "redraw_plot")

func plot_from_source(file : String, _delimiter : String = delimiter) -> void:
	if source == "" or source == null:
		ECUtilities._print_message("Can't plot a chart without a Source file. Please, choose it in editor, or use the custom function _plot().",1)
		return
	
	plot(read_data(file, _delimiter))

func plot_from_dataframe(dataframe : DataFrame) -> void:
	assert(dataframe.headers.size() > 1 or dataframe.labels.size() > 1, 
	"Cannot plot a dataframe of size %sx%s"%[dataframe.headers.size(), dataframe.labels.size()])
	self.dataframe = dataframe
	plot(dataframe.get_dataset())

func plot_placeholder() -> void:
	pass

# Append new data (in array format) to the already plotted data.
# The new data will be appended as a new row of the dataset.
# All data are stored.
func update_plot(new_data : Array = []) -> void:
	if not new_data.empty(): data.append(new_data)
	plot(data if dataframe == null else dataframe.get_dataset().duplicate(true))
	update()

# Append a new column to data
func append_new_column(dataset : Array, column : Array):
	if column.empty():
		ECUtilities._print_message("Can't update plot with an empty row.",1)
		return
	for value_idx in column.size():
		dataset[value_idx].append(column[value_idx])

# ...................... Dataset Manipulation Functions .........................

func read_data(source : String, _delimiter : String = delimiter):
	assert(source != "" and source != null, "A source file must be specified")
	var file : File = File.new()
	file.open(source,File.READ)
	var content : Array
	while not file.eof_reached():
		var line : PoolStringArray = file.get_csv_line(_delimiter)
		if line.empty() or line.size() < 2: 
			continue
		content.append(line)
	file.close()
	return content.duplicate(true)

func slice_x(x_data : Array) -> Array:
	return [x_data[0]] + Array(x_data).slice(x_data.size() - only_disp_values.x, x_data.size() -1 )

func slice_y(y_data : Array) -> Array:
	return [y_data[0]] + y_data.slice(y_data.size()-only_disp_values.y, y_data.size()-1)

## TODO: Data should not be sliced!!
## Instead, only_disp_values should affect all the `range()` to plot points

func slice_data(database : Array) -> Array:
	var data_to_display : Array = database
	if only_disp_values.y < database.size() and only_disp_values.y !=0:
		data_to_display = slice_y(database)
	if only_disp_values.x < database[0].size() and only_disp_values.x !=0:
		for row_idx in database.size():
			data_to_display[row_idx] = slice_x(database[row_idx])
	return data_to_display.duplicate(true)

# ................................. Display and Draw functions .......................
func compute_display():
	count_functions()
	calculate_colors()
	set_shapes()
	create_legend()

func display_plot():
	build_chart()
	calculate_pass()
	calculate_coordinates()

func redraw_plot():
	data_tooltip.hide()
	clean_points()
	display_plot()
	update()

#  ................................. Helper Functions .................................

func load_font():
	if font != null:
		font_size = font.get_height()
		var theme : Theme = Theme.new()
		theme.set_default_font(font)
		set_theme(theme)
	else:
		var lbl = Label.new()
		font = lbl.get_font("")
		lbl.free()
	if bold_font != null:
		data_tooltip.Data.set("custom_fonts/font", bold_font)
	else:
		bold_font = font

func count_functions():
	if are_values_columns: functions = x_labels.size()
	else: functions = y_labels.size()

func calculate_colors():
	if function_colors.size() < functions:
		for function in range(functions - function_colors.size()): function_colors.append(Color(randf(),randf(), randf()))

func set_shapes():
	if points_shape.empty() or points_shape.size() < functions:
		for function in functions:
			points_shape.append(Point.SHAPES.Dot)

# Create the legend of the current plot
func create_legend():
	for function in functions:
		var function_legend : LegendElement 
		if legend.size() > function:
			function_legend = legend[function] 
		else:
			function_legend = legend_element.instance()
			legend.append(function_legend)
		var f_name : String = y_labels[function] if are_values_columns else str(x_labels[function])
		var legend_font : Font
		if font != null:
			legend_font = font
		if bold_font != null:
			legend_font = bold_font
		function_legend.create_legend(f_name,function_colors[function],bold_font,font_color)

func clean_points():
	for function in Points.get_children():
		function.free()
	for legend in Legend.get_children():
		legend.free()

func clean_variables():
	x_chors.clear()
	y_chors.clear()
	x_datas.clear()
	y_datas.clear()
	x_label = ""
	x_labels.clear()
	y_labels.clear()

# .................. VIRTUAL FUNCTIONS .........................
func build_property_list():
	pass


func calculate_tics():
	pass

# Structure the dataset in order to be plotted
func structure_data(database : Array):
	pass

# Calculate borders, size and origin in order to display the plot
func build_chart():
	pass

# Calculate the pass, necessary to correctly draw the points
func calculate_pass():
	pass

# Calculate Points' coordinates in order to display them
func calculate_coordinates():
	pass

# Calculate or assign to each function a color
func function_colors():
	pass

# ........................... Shared Setters & Getters ..............................
func apply_template(template_name : int):
	if Engine.editor_hint:
		set_template(template_name)
		property_list_changed_notify()

func set_data(data : Array) -> void:
	self.data = data

func set_dataframe(dataframe : DataFrame) -> void:
	self.dataframe = dataframe

# !!! API v2 
func set_chart_name(ch_name : String):
	chart_name = ch_name
	get_node("ChartName").set_text(chart_name)

# !!! API v2
func set_source(source_file : String):
	source = source_file

# !!! API v2
func set_indexes(lb : int = 0, function_names : int = 0):
	labels_index = lb
	function_names_index = function_names

# !!! API v2
func set_radius(use_height : bool = false, f : float = 0):
	use_height_as_radius = use_height
	radius = f

# !!! API v2
func set_chart_colors(f_colors : PoolColorArray, o_color : Color, b_color : Color, g_color : Color, h_lines : Color, v_lines : Color):
	function_colors = f_colors
	outline_color = o_color
	box_color = b_color
	grid_color = g_color
	h_lines_color = h_lines
	v_lines_color = v_lines

# !!! API v2
func set_chart_fonts(normal_font : Font, bold_font : Font, f_color : Color = Color.white):
	font = normal_font
	self.bold_font = bold_font
	font_color = f_color

# !!! API v2
func set_delimiter(d : String):
	delimiter = d

# ! API
func set_origin_at_zero(b : bool):
	origin_at_zero = b

# ! API
func set_are_values_columns(b : bool):
	are_values_columns = b

func set_labels_index(i : int):
	labels_index = i

func set_function_names_index(i : int):
	function_names_index = i

func set_use_height_as_radius(b : bool):
	use_height_as_radius = b

func _set_radius(r : float):
	radius = r

func get_radius() -> float:
	if use_height_as_radius: return get_size().y/2
	else: return radius

# ! API
func set_column_width(f : float):
	column_width = f

# ! API
func set_column_gap(f : float):
	column_gap = f

# ! API
func set_full_scale(f : float):
	full_scale = f

# ! API
func set_x_decim(f : float):
	x_decim = f

# ! API
func set_y_decim(f : float):
	y_decim = f

# ! API
func set_points_shape(a : Array):
	points_shape = a


# ! API
func set_function_colors(a : PoolColorArray):
	function_colors = a

# ! API
func set_outline_color(c : Color):
	outline_color = c

# ! API
func set_box_color(c : Color):
	box_color = c

# ! API
func set_tic_length(i: int):
	tic_length = i

# ! API
func set_label_displacement(i:int):
	label_displacement = i

# ! API
func set_grid_color(c : Color):
	grid_color = c

# ! API
func set_grid_lines_width(i : int):
	grid_lines_width = i

# ! API
func set_v_lines_color(c : Color):
	v_lines_color = c

# ! API
func set_h_lines_color(c : Color):
	h_lines_color = c

# ! API
func set_font(f : Font):
	font = f

# ! API
func set_bold_font(f : Font):
	bold_font = f

# ! API
func set_font_color(c : Color):
	font_color = c

func set_use_template(use : bool):
	use_template = use

# ! API
func set_template(template_name : int):
	if not use_template: return
	template = template_name
	if template_name!=null:
		var custom_template = ECUtilities.templates.get(ECUtilities.templates.keys()[template_name])
		function_colors = custom_template.function_colors as PoolColorArray
		outline_color = Color(custom_template.outline_color)
		box_color = Color(custom_template.outline_color)
		grid_color = Color(custom_template.v_lines_color)
		v_lines_color = Color(custom_template.v_lines_color)
		h_lines_color = Color(custom_template.h_lines_color)
		box_color = Color(custom_template.outline_color)
		font_color = Color(custom_template.font_color)

# ! API
func set_rotation(f : float):
	rotation = f

# ! API
func set_invert_chart(b : bool):
	invert_chart = b

# ! API
func set_treshold(t : Vector2):
	treshold = t

# ! API
func set_only_disp_values(v : Vector2):
	only_disp_values = v

func set_legend(l : Array):
	legend = l

func get_legend() -> Array:
	return legend

# ............................. Shared Signals ..............................
func point_pressed(point : Point):
	emit_signal("point_pressed",point)

func show_data(point : Point):
	data_tooltip.update_datas(point)
	data_tooltip.show()

func hide_data():
	data_tooltip.hide()

func show_slice_data(slice : Slice):
	data_tooltip.update_slice_datas(slice)
	data_tooltip.show()
