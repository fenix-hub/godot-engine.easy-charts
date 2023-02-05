extends VBoxContainer
class_name FunctionLegend

onready var f_label_scn: PackedScene = preload("res://addons/easy_charts/utilities/containers/legend/function_label.tscn")

var chart_properties: ChartProperties

func _ready() -> void:
	pass

func add_function(function: Function) -> void:
	var f_label: FunctionLabel = f_label_scn.instance()
	add_child(f_label)
	f_label.init_label(function)
