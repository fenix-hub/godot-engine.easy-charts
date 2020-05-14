tool
extends Node

var plugin_name : String = "Easy Charts"

func _ready():
	pass

func _print_message(message : String, type : int = 0):
	match type:
		0:
			print("[%s] => %s" % [plugin_name, message])
		1:
			printerr("[%s] => %s" % [plugin_name, message])

func _load_templates() -> Dictionary:
	var template_file : File = File.new()
	template_file.open("res://addons/easy_charts/templates.json",File.READ)
	var templates = JSON.parse(template_file.get_as_text()).get_result()
	template_file.close()
	return templates
