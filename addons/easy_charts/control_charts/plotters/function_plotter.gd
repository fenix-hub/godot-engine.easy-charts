extends Control
class_name FunctionPlotter

var function: Function
var chart: Chart

var x_domain: ChartAxisDomain
var y_domain: ChartAxisDomain

static func create_for_function(chart: Chart, function: Function) -> FunctionPlotter:
	match function.get_type():
		Function.Type.LINE:
			return LinePlotter.new(chart, function)
		Function.Type.AREA:
			return AreaPlotter.new(chart, function)
		Function.Type.PIE:
			return PiePlotter.new(chart, function)
		Function.Type.BAR:
			return BarPlotter.new(chart, function)
		Function.Type.SCATTER, _:
			return ScatterPlotter.new(chart, function)

func _init(chart: Chart, function: Function) -> void:
	self.chart = chart
	self.function = function

func _ready() -> void:
	set_process_input(get_chart_properties().interactive)

func update_values(x_domain: ChartAxisDomain, y_domain: ChartAxisDomain) -> void:
	self.visible = self.function.get_visibility()
	if not self.function.get_visibility():
		return
	self.x_domain = x_domain
	self.y_domain = y_domain
	queue_redraw()

func _draw() -> void:
	return

func get_box() -> Rect2:
	return get_parent().get_parent().get_plot_box()

func get_chart_properties() -> ChartProperties:
	return chart.chart_properties

func get_relative_position(position: Vector2) -> Vector2:
	return position - global_position
