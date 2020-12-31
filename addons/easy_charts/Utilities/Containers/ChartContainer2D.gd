tool
extends Node2D

var LineChart = preload("LineChart2D/LineChart2D.tscn")
var ColumnChart = preload("ColumnChart2D/ColumnChart2D.tscn")

export (String,"None","LineChart2D","ColumnChart2D") var chart_type : String setget set_type,get_type
var chart : Node2D setget set_chart,get_chart

# Called when the node enters the scene tree for the first time.
func _ready():
	set_chart(get_child(0))

func set_type(type : String):
	chart_type = type
	var new_node
	if get_children().size():
		for child in get_children():
			child.queue_free()
	if Engine.editor_hint:
		match type:
			"LineChart2D":
				new_node = LineChart.instance()
				add_child(new_node)
				new_node.set_owner(owner)
			"ColumnChart2D":
				new_node = ColumnChart.instance()
				add_child(new_node)
				new_node.set_owner(owner)
			"None":
				set_chart(null)

func get_type():
	return chart_type

func set_chart(ch : Node2D):
	chart = ch

func get_chart():
	return chart
