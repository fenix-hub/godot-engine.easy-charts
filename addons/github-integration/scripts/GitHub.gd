# ----------------------------------------------
#            ~{ GitHub Integration }~
# [Author] Nicolò "fenix" Santilio 
# [github] fenix-hub/godot-engine.github-integration
# [version] 0.2.9
# [date] 09.13.2019





# -----------------------------------------------

tool
extends Control

onready var VersionCheck : HTTPRequest = $VersionCheck

onready var SignIn = $SingIn
onready var UserPanel = $UserPanel
onready var CommitRepo = $Commit
onready var Repo = $Repo
onready var Gist = $Gist
onready var Commit = $Commit
onready var LoadNode = $loading
onready var Version = $Header/datas/version
onready var ConnectionIcon : TextureRect = $Header/datas/connection
onready var Header = $Header
onready var RestartConnection = Header.get_node("datas/restart_connection")


onready var Menu = $Header/datas/Menu.get_popup()

var user_avatar : ImageTexture = ImageTexture.new()
var user_img = Image.new()

var connection_status : Array = [
    IconLoaderGithub.load_icon_from_name("searchconnection"),
    IconLoaderGithub.load_icon_from_name("noconnection"),
    IconLoaderGithub.load_icon_from_name("connection")
]

var plugin_version
var plugin_name

func load_config():
    var config =  ConfigFile.new()
    var err = config.load("res://addons/github-integration/plugin.cfg")
    if err == OK:
        plugin_version = config.get_value("plugin","version")
        plugin_name = "[%s] >> " % config.get_value("plugin","name")

func _ready():
    load_config()
    
    set_darkmode(PluginSettings.darkmode)
    
    LoadNode.hide()
    Menu.connect("id_pressed", self, "menu_item_pressed")
    RestartConnection.connect("pressed",self,"check_connection")
    VersionCheck.connect("request_completed",self,"_on_version_check")
#    Debug.connect("toggled",self,"_on_debug_toggled")
    
    Repo.hide()
    SignIn.show()
    SignIn.connect("signed",self,"signed")
    UserPanel.hide()
    Commit.hide()
    
    Version.text = "v "+plugin_version
#    Debug.set_pressed(PluginSettings.debug)
    ConnectionIcon.set_texture(connection_status[0])
    
#    check_connection()
    ConnectionIcon.use_parent_material = false
    ConnectionIcon.material.set("shader_param/speed", 3)
    RestHandler.check_connection()
    var connection = yield(RestHandler, "_check_connection")
    match connection:
        true:
            SignIn.btnSignIn.set_disabled(false)
            ConnectionIcon.set_texture(connection_status[2])
            ConnectionIcon.set_tooltip("Connected to GitHub API")
            RestartConnection.hide()
        false:
            SignIn.btnSignIn.set_disabled(true)
            ConnectionIcon.set_texture(connection_status[1])
            ConnectionIcon.set_tooltip("Can't connect to GitHub API, check your internet connection or API status")
            RestartConnection.show()
    ConnectionIcon.use_parent_material = true
    ConnectionIcon.material.set("shader_param/speed", 0)
    
    Menu.set_item_checked(0, PluginSettings.debug)
    Menu.set_item_checked(1, PluginSettings.auto_log)
    VersionCheck.request("https://api.github.com/repos/fenix-hub/godot-engine.github-integration/tags",[],false,HTTPClient.METHOD_GET,"")
    
    if PluginSettings.auto_log:
        SignIn.sign_in()

func check_connection():
    pass

func loading(value : bool) -> void:
    LoadNode.visible = value

func show_loading_progress(value : float,  max_value : float) -> void:
    LoadNode.show_progress(value,max_value)

func hide_loading_progress():
    LoadNode.hide_progress()

func show_number(value : float, type : String) -> void:
    LoadNode.show_number(value,type)

func hide_number():
    LoadNode.hide_number()

func signed() -> void:
    UserPanel.load_panel()
    set_avatar(UserData.AVATAR)
    set_username(UserData.USER.login)

func print_debug_message(message : String = "",type : int = 0):
    if PluginSettings.debug == true:
        match type:
            0:
                print(plugin_name,message)
            1:
                printerr(plugin_name,message)
            2:
                push_warning(plugin_name+message)

func _on_debug_toggled(button_pressed):
    PluginSettings.set_debug(button_pressed)
    Menu.set_item_checked(0, PluginSettings.debug)
    if button_pressed:
        print(plugin_name, "Debug Enabled")
    else:
        print(plugin_name, "Debug Disabled")

func _on_autologin_toggled(button_pressed):
    PluginSettings.set_auto_log(button_pressed)
    Menu.set_item_checked(1, PluginSettings.auto_log)
    if button_pressed:
        print(plugin_name, "Auto Login Enabled")
    else:
        print(plugin_name, "Auto Login Disabled")
        

func menu_item_pressed(id : int):
    match id:
        0:
            _on_debug_toggled(!Menu.is_item_checked(id))
        1:
            _on_autologin_toggled(!Menu.is_item_checked(id))
        3:
            OS.shell_open("https://github.com/fenix-hub/godot-engine.github-integration/wiki")
        5:
            logout()
        7:
            set_darkmode(!Menu.is_item_checked(id))

func logout():
    set_avatar(IconLoaderGithub.load_icon_from_name("circle"))
    set_username("user")
    SignIn.show()
    UserPanel.hide()
    Repo.hide()
    Commit.hide()
    Gist.hide()
    SignIn.Mail.text = ""
    SignIn.Token.text = ""

func set_darkmode(darkmode : bool):
    PluginSettings.set_darkmode(darkmode)
    Menu.set_item_checked(7, PluginSettings.darkmode)
    SignIn.set_darkmode(darkmode)
    UserPanel.set_darkmode(darkmode)
    Repo.set_darkmode(darkmode)
    Commit.set_darkmode(darkmode)
    Gist.set_darkmode(darkmode)
    Header.set_darkmode(darkmode)
        

func set_avatar(avatar : ImageTexture):
    $Header/datas/avatar.texture = avatar

func set_username(username : String):
    $Header/datas/user.text = username

func _on_version_check(result, response_code, headers, body ):
    if result == 0:
        if response_code == 200:
            var tags : Array = JSON.parse(body.get_string_from_utf8()).result
            var first_tag : Dictionary = tags[0] as Dictionary
            if first_tag.name != ("v"+plugin_version):
                print_debug_message("a new plugin version has been found, current version is %s and new version is %s" % [("v"+plugin_version), first_tag.name],1)
