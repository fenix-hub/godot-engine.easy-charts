tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("ECUtilities","res://addons/easy_charts/utilities/scripts/ec_utilities.gd")

func _exit_tree():
	remove_autoload_singleton("ECUtilities")

