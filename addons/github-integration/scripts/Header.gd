tool
extends Control

onready var discord : TextureButton = $datas/discord
onready var paypal : TextureButton = $datas/paypal
onready var github : TextureButton = $datas/github

func _ready():
    discord.connect("pressed",self,"_join_discord")
    paypal.connect("pressed",self,"_support_paypal")
    github.connect("pressed",self,"_check_git")

func set_darkmode(darkmode : bool):
    if darkmode:
        set_theme(load("res://addons/github-integration/resources/themes/GitHubTheme-Dark.tres"))
    else:
        set_theme(load("res://addons/github-integration/resources/themes/GitHubTheme.tres"))

func _join_discord():
    OS.shell_open("https://discord.gg/KnJGY9S")

func _support_paypal():
    OS.shell_open("https://paypal.me/NSantilio?locale.x=it_IT")

func _check_git():
    OS.shell_open("https://github.com/fenix-hub/godot-engine.github-integration")
