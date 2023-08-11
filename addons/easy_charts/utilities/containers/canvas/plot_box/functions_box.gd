extends PanelContainer
class_name FunctionsBox


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _draw() -> void:
	update_functions_values(owner.x_domain, owner.y_domain)


func add_function_plotter(function_plotter: FunctionPlotter) -> void:
	pass


func add_function(function: Function) -> void:
	var function_plotter: FunctionPlotter = get_function_plotter(function)
	function_plotter.point_entered.connect(owner._on_function_point_entered)
	function_plotter.point_exited.connect(owner._on_function_point_exited)
	add_child(function_plotter)


func update_functions_values(x_domain: Dictionary, y_domain: Dictionary) -> void:
	for function_plotter in get_children():
		function_plotter.update_values(x_domain, y_domain)


func get_function_plotter(function: Function) -> FunctionPlotter:
	var plotter: FunctionPlotter
	match function.get_type():
		Function.Type.LINE:
			plotter = LinePlotter.new(function)
		Function.Type.AREA:
			plotter = AreaPlotter.new(function)
		Function.Type.PIE:
			plotter = PiePlotter.new(function)
		Function.Type.BAR:
			plotter = BarPlotter.new(function)
		Function.Type.SCATTER, _:
			plotter = ScatterPlotter.new(function)
	return plotter
