tool
extends Container

var LineChart = preload("LineChart/LineChart.tscn")

export (String,"None","LineChart","BoxChart") var chart_type : String setget set_type,get_type
var chart : Control setget set_chart,get_chart
var templates : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	set_chart(get_child(0))
	var template_file : File = File.new()
	template_file.open("res://addons/easy_charts/templates.json",File.READ)
	templates = JSON.parse(template_file.get_as_text()).get_result()
	template_file.close()

func set_type(type : String):
	chart_type = type
	var new_node
	if get_children().size():
		for child in get_children():
			child.queue_free()
	if Engine.editor_hint:
		match type:
			"LineChart":
				new_node = LineChart.instance()
				add_child(new_node)
				new_node.set_owner(owner)
			"None":
				set_chart(null)

func get_type():
	return chart_type

func set_chart(ch : Control):
	chart = ch

func get_chart():
	return chart
