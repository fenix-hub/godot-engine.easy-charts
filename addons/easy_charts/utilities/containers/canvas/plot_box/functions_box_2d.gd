extends Control
class_name FunctionsBox2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add_function_plotter(function_plotter: FunctionPlotter2D) -> void:
	pass


func add_function(function: Function) -> void:
	var function_plotter: FunctionPlotter2D = get_function_plotter(function)
	function_plotter.point_entered.connect(Callable(get_parent_control(), "_on_point_entered"))
	function_plotter.point_exited.connect(Callable(get_parent_control(), "_on_point_exited"))
	add_child(function_plotter)


func update_functions_values(x_domain: Dictionary, y_domain: Dictionary) -> void:
	for function_plotter in get_children():
		function_plotter.update_values(x_domain, y_domain)


func get_function_plotter(function: Function) -> FunctionPlotter2D:
	var plotter: FunctionPlotter2D
	match function.get_type():
#		Function.Type.LINE:
#			plotter = LinePlotter.new(function)
#		Function.Type.AREA:
#			plotter = AreaPlotter.new(function)
#		Function.Type.PIE:
#			plotter = PiePlotter.new(function)
#		Function.Type.BAR:
#			plotter = BarPlotter.new(function)
		Function.Type.SCATTER, _:
			plotter = ScatterPlotter2D.new(function)
	return plotter

func _on_item_rect_changed():
	for plotter in get_children():
		plotter.queue_redraw()
