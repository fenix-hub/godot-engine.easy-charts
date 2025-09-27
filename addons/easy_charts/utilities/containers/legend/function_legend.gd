extends VBoxContainer
class_name FunctionLegend

signal function_clicked(function: Function)

@onready var function_label_scene: PackedScene = preload("res://addons/easy_charts/utilities/containers/legend/function_label.tscn")

var chart_properties: ChartProperties

func _ready() -> void:
	pass

func clear() -> void:
	for label in get_children():
		label.queue_free()

func add_function(function: Function) -> void:
	var function_label: FunctionLabel = function_label_scene.instantiate()
	add_child(function_label)
	function_label.clicked.connect(function_clicked.emit.bind(function))
	function_label.init_label(function)

func add_label(type: int, color: Color, name: String) -> void:
	var function_label: FunctionLabel = function_label_scene.instantiate()
	add_child(function_label)
	function_label.init_clabel(type, color, name)
