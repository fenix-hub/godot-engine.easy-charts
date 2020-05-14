tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("Utilities","res://addons/easy_charts/Utilities/utilities.gd")
	add_custom_type("ChartContainer", "Container", load("Utilities/ChartContainer.gd"), load("Utilities/icons/linechart.svg"))
	add_custom_type("ChartContainer2D", "Node2D", load("Utilities/ChartContainer2D.gd"), load("Utilities/icons/linechart2d.svg"))

func _exit_tree():
	remove_custom_type("ChartContainer")
	remove_custom_type("ChartContainer2D")
	remove_autoload_singleton("Utilities")
