tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("Utilities","res://addons/easy_charts/Utilities/Scripts/utilities.gd")
	add_custom_type("Chart","Control", load("res://addons/easy_charts/Utilities/Scripts/chart.gd"), preload("Utilities/icons/linechart.svg"))
	add_custom_type("Chart2D","Node2D", load("res://addons/easy_charts/Utilities/Scripts/chart2d.gd"), preload("Utilities/icons/linechart2d.svg"))

func _exit_tree():
	remove_custom_type("Chart")
	remove_custom_type("Chart2D")
	remove_autoload_singleton("Utilities")
