tool
extends PanelContainer

signal gist_selected(repo)
signal gist_clicked(repo)

onready var Name = $Gist/Name
onready var Files = $Gist/Files
onready var BG = $BG

var _name : String
var _files : int
var _metadata : Dictionary
var _gist : Dictionary

func _ready():
    Files.get_node("Icon").set_texture(IconLoaderGithub.load_icon_from_name("gists"))

func set_gist(gist : Dictionary):
    _gist = gist
    _name = gist.files.values()[0].filename
    _files = gist.files.size()
    Name.get_node("Text").set_text(_name)
    Files.get_node("Amount").set_text("Files: "+str(_files))
    
    var gist_icon : ImageTexture 
    if gist.public:
        gist_icon = (IconLoaderGithub.load_icon_from_name("gists"))
    else:
        gist_icon = (IconLoaderGithub.load_icon_from_name("lock"))
    Name.get_node("Icon").set_texture(gist_icon)

func deselect():
    BG.hide()

func _on_GistItem_gui_input(event):
    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == 1:
            BG.show()
            emit_signal("gist_clicked", _gist)
        if event.doubleclick:
            emit_signal("gist_selected", _gist)
