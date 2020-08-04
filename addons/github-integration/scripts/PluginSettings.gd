tool
extends Node

var directory_name = "github_integration"
var plugin_path : String = ProjectSettings.globalize_path("user://").replace("app_userdata/"+ProjectSettings.get_setting('application/config/name')+"/",directory_name)+"/"

var setting_file : String = "settings.cfg"

var debug : bool = true
var auto_log : bool = false
var darkmode : bool = false

func _ready():
    var config_file : ConfigFile = ConfigFile.new()
    var err = config_file.load(plugin_path+setting_file)
    if err == OK:
        debug = config_file.get_value("settings","debug", debug)
        auto_log = config_file.get_value("settings","auto_log", auto_log)
        darkmode = config_file.get_value("settings","darkmode", darkmode)
    else:
        config_file.save(plugin_path+setting_file)
        config_file.set_value("settings","debug",debug)
        config_file.set_value("settings","auto_log",auto_log)
        config_file.set_value("settings","darkmode",darkmode)
        config_file.save(plugin_path+setting_file)

func set_debug(d : bool):
    debug = d
    save_setting("debug", debug)

func set_auto_log(a : bool):
    auto_log = a
    save_setting("auto_log", auto_log)

func set_darkmode(d : bool):
    darkmode = d
    save_setting("darkmode", darkmode)

func save_setting(key : String, value):
    var file : ConfigFile = ConfigFile.new()
    var err = file.load(plugin_path+setting_file)
    if err == OK:
        file.set_value("settings",key,value)
    file.save(plugin_path+setting_file)
