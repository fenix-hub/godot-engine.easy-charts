tool
extends Node

var plugin_name : String = "Easy Charts"
var templates : Dictionary = {}
var chart_types : Dictionary = {
	0:"LineChart",
	1:"ColumnChart",
	2:"ScatterChart",
	3:"RadarChart",
	4:"PieChart"
}

func _ready():
	templates = _load_templates()

#    _print_message("Templates loaded")

func _print_message(message : String, type : int = 0):
	match type:
		0:
			print("[%s] => %s" % [plugin_name, message])
		1:
			printerr("ERROR: [%s] => %s" % [plugin_name, message])

func _load_templates() -> Dictionary:
	var template_file : File = File.new()
	template_file.open("res://addons/easy_charts/templates.json",File.READ)
	var templates = JSON.parse(template_file.get_as_text()).get_result()
	template_file.close()
	return templates

func get_template(template_index : int):
	return templates.get(templates.keys()[template_index])

func get_chart_type(chart_type : int):
	return chart_types.get(chart_types.keys()[chart_type])
