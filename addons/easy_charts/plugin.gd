tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("ECUtilities","res://addons/easy_charts/utilities/scripts/ec_utilities.gd")
	add_custom_type("Chart","Control", load("res://addons/easy_charts/utilities/classes/base/chart.gd"), preload("utilities/icons/linechart.svg"))
	add_custom_type("Chart2D","Node2D", load("res://addons/easy_charts/utilities/classes/base/chart2d.gd"), preload("utilities/icons/linechart2d.svg"))

func _exit_tree():
	remove_custom_type("Chart")
	remove_custom_type("Chart2D")
	remove_autoload_singleton("ECUtilities")

