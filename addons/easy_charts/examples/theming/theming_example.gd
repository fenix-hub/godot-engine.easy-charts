extends Panel

@onready var _vbox_container: Container = $MarginContainer/VBoxContainer
@onready var _theme_options_button: OptionButton = %ThemeOptionButton

var _chart_scene := preload("res://addons/easy_charts/control_charts/chart.tscn")
var _chart: Chart
var _chart_properties: ChartProperties

func _ready() -> void:
	_chart_properties = ChartProperties.new()
	_chart_properties.show_legend = true
	_chart_properties.interactive = true

	_theme_options_button.item_selected.connect(_on_theme_option_button_item_selected)
	_theme_options_button.selected = 0
	_on_theme_option_button_item_selected(_theme_options_button.selected)

func _draw_chart() -> void:
	if _chart != null:
		_vbox_container.remove_child(_chart)
		_chart.queue_free()
		_chart = null

	var x: Array = ArrayOperations.multiply_float(range(-10, 11, 1), 0.5)
	var y: Array = ArrayOperations.multiply_int(ArrayOperations.cos(x), 20)
	var color: Color = Color.DARK_BLUE
	if _theme_options_button.selected == 1 || _theme_options_button.selected == 3:
		color = Color.GREEN
	var f = Function.new(x, y, "Pressure", { color = color, marker = Function.Marker.CIRCLE })

	_chart = _chart_scene.instantiate()
	_vbox_container.add_child(_chart)
	_chart.set_y_domain(-50, 50)
	_chart.plot([f], _chart_properties)

func _on_theme_option_button_item_selected(index: int) -> void:
	var selected_theme: Theme
	match index:
		0: selected_theme = load("res://addons/easy_charts/control_charts/default_chart_theme.tres")
		1: selected_theme = load("res://addons/easy_charts/control_charts/dark_chart_theme.tres")
		2: selected_theme = load("res://addons/easy_charts/examples/theming/theming_example_blue.tres")
		3: selected_theme = load("res://addons/easy_charts/examples/theming/theming_example_funny.tres")
	theme = selected_theme
	_draw_chart()
