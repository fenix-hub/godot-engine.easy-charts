# ----------------------------------------------
#            ~{ GitHub Integration }~
# [Author] Nicolò "fenix" Santilio 
# [github] fenix-hub/godot-engine.github-integration
# [version] 0.2.9
# [date] 09.13.2019





# -----------------------------------------------

tool
extends EditorPlugin
var doc
var IconLoaderGithub = preload("res://addons/github-integration/scripts/IconLoaderGithub.gd").new()
var GitHubDoc

func _enter_tree():
    self.add_autoload_singleton("PluginSettings","res://addons/github-integration/scripts/PluginSettings.gd")
    self.add_autoload_singleton("IconLoaderGithub","res://addons/github-integration/scripts/IconLoaderGithub.gd")
    self.add_autoload_singleton("RestHandler","res://addons/github-integration/scenes/RestHandler.tscn")
    self.add_autoload_singleton("UserData","res://addons/github-integration/scripts/user_data.gd")
    doc = load("res://addons/github-integration/scenes/GitHub.tscn")
    GitHubDoc = doc.instance()
    get_editor_interface().get_editor_viewport().add_child(GitHubDoc)
    GitHubDoc.hide()


func _exit_tree():
    self.remove_autoload_singleton("PluginSettings")
    self.remove_autoload_singleton("IconLoaderGithub")
    self.remove_autoload_singleton("RestHandler")
    self.remove_autoload_singleton("UserData")
    get_editor_interface().get_editor_viewport().remove_child(GitHubDoc)
    GitHubDoc.queue_free()

func has_main_screen():
    return true

func get_plugin_name():
    return "GitHub"

func get_plugin_icon():
    return IconLoaderGithub.load_icon_from_name("githubicon")

func make_visible(visible):
    GitHubDoc.visible = visible

