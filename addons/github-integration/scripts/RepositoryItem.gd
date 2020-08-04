tool
extends PanelContainer

signal repo_selected(repo)
signal repo_clicked(repo)

onready var Name = $Repository/Name
onready var Stars = $Repository/Stars
onready var Forks = $Repository/Forks
onready var BG = $BG

var _name : String
var _stars : int
var _forks : int
var _metadata : Dictionary
var _repository : Dictionary

func _ready():
    Stars.get_node("Icon").set_texture(IconLoaderGithub.load_icon_from_name("stars"))
    Forks.get_node("Icon").set_texture(IconLoaderGithub.load_icon_from_name("forks"))

func set_repository(repository : Dictionary):
    _repository = repository
    _name = str(repository.name)
    _stars = repository.stargazers_count
    _forks = repository.forks_count
    Name.get_node("Text").set_text(_name)
    Stars.get_node("Amount").set_text("Stars: "+str(_stars))
    Forks.get_node("Amount").set_text("Forks: "+str(_forks))
    
    var repo_icon : ImageTexture
    if repository.private:
        repo_icon = IconLoaderGithub.load_icon_from_name("lock")
    else:
        if repository.fork:
            repo_icon = IconLoaderGithub.load_icon_from_name("forks")
        else:
            repo_icon = IconLoaderGithub.load_icon_from_name("repos")
    Name.get_node("Icon").set_texture(repo_icon)

func deselect():
    BG.hide()

func _on_RepositoryItem_gui_input(event):
    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == 1:
            BG.show()
            emit_signal("repo_clicked", _repository)
        if event.doubleclick:
            emit_signal("repo_selected", _repository)
