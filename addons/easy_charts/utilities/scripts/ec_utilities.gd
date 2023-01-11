tool
extends Node

var alphabet : String = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"

func _ready():
	pass
#	templates = _load_templates()

func _print_message(message : String, type : int = 0):
	pass
#	match type:
#		0:
#			print("[%s] => %s" % [plugin_name, message])
#		1:
#			printerr("ERROR: [%s] => %s" % [plugin_name, message])

func _load_templates() -> Dictionary:
	pass
	return {}
#	var template_file : File = File.new()
#	template_file.open("res://addons/easy_charts/templates.json",File.READ)
#	var templates = JSON.parse(template_file.get_as_text()).get_result()
#	template_file.close()
#	return templates

func get_template(template_index : int):
	pass
#	return templates.get(templates.keys()[template_index])

func get_chart_type(chart_type : int) -> Array:
	pass
	return []
#	return chart_types.get(chart_types.keys()[chart_type])

func get_letter_index(index : int) -> String:
	return alphabet.split(" ")[index]

func save_dataframe_to_file(dataframe: DataFrame, path: String, delimiter: String = ";") -> void:
	pass
#	var file = File.new()
#	file.open(path, File.WRITE)
#	for row in dataframe.get_dataset():
#		file.store_line(PoolStringArray(row).join(delimiter))
#	file.close()

