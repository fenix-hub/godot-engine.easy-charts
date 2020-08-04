tool
extends WindowDialog

onready var description = $VBoxContainer/HBoxContainer/description

onready var FromProject = $VBoxContainer/HBoxContainer4/Button
onready var NewGists = $VBoxContainer/HBoxContainer4/Button2
onready var GistFiles = $FileDialog

onready var privacy = $VBoxContainer/HBoxContainer3/privacy

var filelist 

var EXTENSIONS : PoolStringArray = [
"*.txt ; Plain Text File", 
"*.rtf ; Rich Text Format File", 
"*.log ; Log File", 
"*.md ; MD File",
"*.doc ; WordPad Document",
"*.doc ; Microsoft Word Document",
"*.docm ; Word Open XML Macro-Enabled Document",
"*.docx ; Microsoft Word Open XML Document",
"*.bbs ; Bulletin Board System Text",
"*.dat ; Data File",
"*.xml ; XML File",
"*.sql ; SQL database file",
"*.json ; JavaScript Object Notation File",
"*.html ; HyperText Markup Language",
"*.csv ; Comma-separated values",
"*.cfg ; Configuration File",
"*.ini ; Initialization File (same as .cfg Configuration File)",
"*.csv ; Comma-separated values File",
]

func _ready():
	NewGists.connect("pressed",self,"on_newgists_pressed")
	FromProject.connect("pressed",self,"on_fromproject_pressed")
	GistFiles.connect("files_selected",self,"on_files_selected")
	GistFiles.set_filters(EXTENSIONS)

func on_newgists_pressed():
	var priv
	if privacy.get_selected_id() == 0:
		priv = true
	else:
		priv = false
	
	var desc 
	desc = description.get_text()
	
	get_parent().get_parent().Gist.initialize_new_gist(priv,desc)
	hide()
	get_parent().hide()

func on_fromproject_pressed():
	GistFiles.popup()

func on_files_selected(files : PoolStringArray):
	var priv
	if privacy.get_selected_id() == 0:
		priv = true
	else:
		priv = false
	
	var desc 
	desc = description.get_text()
	get_parent().get_parent().Gist.initialize_new_gist(priv,desc,files)
	hide()
	get_parent().hide()

