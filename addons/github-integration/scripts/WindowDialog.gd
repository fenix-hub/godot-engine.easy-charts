# ----------------------------------------------
#            ~{ GitHub Integration }~
# [Author] Nicolò "fenix" Santilio 
# [github] fenix-hub/godot-engine.github-integration
# [version] 0.2.9
# [date] 09.13.2019



# -----------------------------------------------

tool
extends Control


onready var gitignore = $VBoxContainer/HBoxContainer5/gitignore
onready var privacy = $VBoxContainer/HBoxContainer3/privacy
onready var readme = $VBoxContainer/HBoxContainer4/readme
onready var license = $VBoxContainer/HBoxContainer6/license
onready var nome = $VBoxContainer/HBoxContainer/nome
onready var descrizione = $VBoxContainer/HBoxContainer2/descrizione

enum REQUESTS { REPOS = 0, GISTS = 1, END = -1 }
var requesting
var new_repo = HTTPRequest.new()
var repo_body

var LICENSES = ["afl-3.0","apache-2.0","artistic-2.0","bsl-1.0","bsd-2-clause","bsd-3-clause","bsd-3-clause-clear","cc","cc0-1.0","cc-by-4.0","cc-by-sa-4.0","wtfpl","ecl-2.0","epl-1.0","eupl-1.1",
"agpl-3.0","gpl","gpl-2.0","gpl-3.0","lgpl","lgpl-2.1","lgpl-3.0","isc","lppl-1.3c","ms-pl","mit","mpl-2.0","osl-3.0","postgresql","ofl-1.1","ncsa","unlicense","zlib"]

#var GITIGNORE = ["Haskell","Godot"]

onready var error = $VBoxContainer/error

func _ready():
    call_deferred("add_child",new_repo)
    new_repo.connect("request_completed",self,"request_completed")
    gitignore.select(0)
    license.select(0)
    error.hide()
    load_metadata()

func load_metadata():
    for l in range(0,license.get_item_count()):
        license.set_item_metadata(l,LICENSES[l])
#	for g in range(0,gitignore.get_item_count()):
#		gitignore.set_item_metadata(g,GITIGNORE[g])

func request_completed(result, response_code, headers, body ):
    if result == 0:
        match requesting:
            REQUESTS.REPOS:
                if response_code == 201:
                    hide()
                    get_parent().print_debug_message("created new repository...")
                    get_parent().UserPanel.request_repositories(get_parent().UserPanel.REQUESTS.UP_REPOS)
                    get_parent().loading(false)
                elif response_code == 422:
                    error.text = "Error: "+JSON.parse(body.get_string_from_utf8()).result.errors[0].message
                    error.show()
            REQUESTS.GISTS:
                if response_code == 200:
                    pass

func load_body() -> Dictionary:
    var priv
    if privacy.get_selected_id() == 0:
        priv = true
    else:
        priv = false
    
    var read
    if readme.pressed:
        read = true
    else:
        read = false
    
    var gitignor = gitignore.get_item_text(gitignore.get_selected_id())
    var licens = license.get_item_metadata(license.get_selected_id())
    
    repo_body = {
        "name": nome.get_text(),
        "description": descrizione.get_text(),
        "private": priv,
        "has_issues": true,
        "has_projects": true,
        "has_wiki": true,
        "auto_init": read,
        "gitignore_template": gitignor,
        "license_template":  licens
        }
    
    return repo_body

func _on_NewRepo_confirmed():
    get_parent().loading(true)
    error.hide()
    requesting = REQUESTS.REPOS
    new_repo.request("https://api.github.com/user/repos",UserData.header,false,HTTPClient.METHOD_POST,JSON.print(load_body()))


