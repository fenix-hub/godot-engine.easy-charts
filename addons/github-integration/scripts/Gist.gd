tool
extends Control


onready var CloseBTN = $GistContainer/close
onready var List = $GistContainer/GistEditor/ListContainer/List
onready var ListBar = $GistContainer/GistEditor/ListContainer/ListBar
onready var Content = $GistContainer/GistEditor/ContentContainer/Content
onready var GistName = $GistContainer/gist_name
onready var GistDescription = $GistContainer/description/gist_description
onready var WrapButton = $GistContainer/GistEditor/ContentContainer/TopBar/WrapBtn
onready var MapButton = $GistContainer/GistEditor/ContentContainer/TopBar/MapBtn
onready var NewFileDialog = $NewFile
onready var Readonly = $GistContainer/GistEditor/ContentContainer/TopBar/Readonly

onready var edit_description = $GistContainer/description/edit_description

onready var addfile_btn = $GistContainer/GistEditor/ListContainer/ListBar/addfile
onready var deletefile_btn = $GistContainer/GistEditor/ListContainer/ListBar/deletefile
onready var commit_btn = $GistContainer/GistButtons/commit
onready var delete_btn = $GistContainer/GistButtons/delete

var request = HTTPRequest.new()
enum REQUESTS { REPOS = 0, GIST = 1, UP_REPOS = 2, UP_GISTS = 3, DELETE = 4, COMMIT = 5, BRANCHES = 6, CONTENTS = 7, TREES = 8, DELETE_RESOURCE = 9, END = -1 }
var requesting

var privacy : bool
var description : String
var gistid : String


enum GIST_MODE { CREATING = 0 , GETTING = 1 , EDITING = 2 }
var gist_mode

#signals
signal get_gist()
signal loaded_gist()
signal gist_committed()
signal gist_updated()
signal gist_deleted()

func _ready():
    add_child(request)
    connect_signals()
    Readonly.set_pressed(true)
    hide()

func set_darkmode(darkmode : bool):
    if darkmode:
        $BG.color = "#24292e"
        set_theme(load("res://addons/github-integration/resources/themes/GitHubTheme-Dark.tres"))
    else:
        $BG.color = "#f6f8fa"
        set_theme(load("res://addons/github-integration/resources/themes/GitHubTheme.tres"))

func connect_signals():
    request.connect("request_completed",self,"request_completed")
    CloseBTN.connect("pressed",self,"close_editor")
    List.connect("item_selected",self,"on_item_selected")
    WrapButton.connect("item_selected",self,"on_wrap_selected")
    MapButton.connect("item_selected",self,"on_btn")
    
    addfile_btn.connect("pressed",self,"on_addfile")
    deletefile_btn.connect("pressed",self,"on_deletefile")
    commit_btn.connect("pressed",self,"on_commit")
    delete_btn.connect("pressed",self,"on_delete")
    
    NewFileDialog.connect("confirmed",self,"add_new_file")
    
    Content.connect("text_changed",self,"on_text_changed")
    
    Readonly.connect("toggled",self,"_on_Readonly_toggled")
    
    addfile_btn.set_button_icon(IconLoaderGithub.load_icon_from_name("file-gray"))
    deletefile_btn.set_button_icon(IconLoaderGithub.load_icon_from_name("file_broken"))

func request_completed(result, response_code, headers, body ):
#	print(JSON.parse(body.get_string_from_utf8()).result)
    if result == 0:
        match requesting:
            REQUESTS.GIST:
                if response_code == 200:
                    load_gist(JSON.parse(body.get_string_from_utf8()).result)
                    emit_signal("get_gist")
            REQUESTS.COMMIT:
                if response_code == 201:
                    GistName.set_text(UserData.USER.login+"/"+JSON.parse(body.get_string_from_utf8()).result.files.values()[0].filename)
                    get_parent().print_debug_message("gist committed with success!")
                    get_parent().UserPanel.request_gists(REQUESTS.GIST)
                    emit_signal("gist_committed")
            REQUESTS.UP_GISTS:
                if response_code == 200:
                    get_parent().print_debug_message("gist updated with success!")
                    get_parent().UserPanel.request_gists(REQUESTS.GIST)
                    emit_signal("gist_updated")
            REQUESTS.DELETE:
                if response_code == 204:
                    get_parent().print_debug_message("gist deleted with success!")
                    get_parent().UserPanel.request_gists(REQUESTS.GIST)
                    emit_signal("gist_deleted")

func request_gist(gist_id : String):
    gist_mode = GIST_MODE.GETTING
    requesting = REQUESTS.GIST
    gistid = gist_id
    commit_btn.hide()
    edit_description.hide()
    commit_btn.set_text("Update Gist")
    commit_btn.set_button_icon(IconLoaderGithub.load_icon_from_name("edit_"))
    request.request("https://api.github.com/gists/"+gist_id,UserData.header,false,HTTPClient.METHOD_GET,"")
    yield(self,"get_gist")

func load_gist(gist : Dictionary):
    delete_btn.show()
    ListBar.hide()
    Content.set_readonly(true)
    GistName.set_text(UserData.USER.login+"/"+gist.files.values()[0].filename)
    if gist.description=="" or gist.description==" " or gist.description==null:
        GistDescription.set_text("<no description>")
    else:
        GistDescription.set_text(gist.description)
    
    description = gist.description
    
    for file in gist.files:
        
        var file_item = List.add_item(file,IconLoaderGithub.load_icon_from_name("gists-back"))
        var this_index = List.get_item_count()-1
        List.set_item_metadata(this_index,gist.files[file])
        List.select(this_index)
        on_item_selected(this_index)
    
    show()
    emit_signal("loaded_gist")

func on_item_selected(index : int):
    Content.clear_colors()
    var item_metadata = List.get_item_metadata(index)
    color_region(item_metadata.filename.get_extension())
    Content.set_text(item_metadata.content)

func close_editor():
    List.clear()
    Content.set_text("")
    GistName.set_text("")
    GistDescription.set_text("")
    hide()
    get_parent().UserPanel.show()

func on_wrap_selected(index : int):
    match index:
        0:
            Content.set_wrap_enabled(false)
        1:
            Content.set_wrap_enabled(true)

func initialize_new_gist(privacy : bool , description : String = "" , files : PoolStringArray = []):
    delete_btn.hide()
    gist_mode = GIST_MODE.CREATING
    commit_btn.set_button_icon(IconLoaderGithub.load_icon_from_name("add-gray"))
    self.privacy = privacy
    self.description = description
    if description == "" or description ==  " ":
        GistDescription.hide()
    GistDescription.set_text(description)
    GistName.set_text("New Gist")
    Content.set_readonly(false)
    ListBar.show()
    commit_btn.show()
    commit_btn.set_text("Commit Gist")
    
    if files.size():
        for file in files:
            var gist_file = File.new()
            gist_file.open(file,File.READ)
            var filecontent = gist_file.get_as_text()
            gist_file.close()
            load_file(file.get_file(),filecontent)
    
    show()

func on_addfile():
    NewFileDialog.popup()

func load_file(file_name : String, filecontent : String):
    var file_item = List.add_item(file_name,IconLoaderGithub.load_icon_from_name("gists-back"))
    var this_index = List.get_item_count()-1
    
    var metadata = { "content":filecontent, "filename":file_name }
    
    List.set_item_metadata(this_index,metadata)
    List.select(this_index)
    on_item_selected(this_index)

func add_new_file():
    var item_filename = NewFileDialog.get_node("HBoxContainer2/filename").get_text()
    NewFileDialog.get_node("HBoxContainer2/filename").set_text("")
    var file_item = List.add_item(item_filename,IconLoaderGithub.load_icon_from_name("gists-back"))
    var this_index = List.get_item_count()-1
    
    var metadata = { "content":"", "filename":item_filename }
    
    
    List.set_item_metadata(this_index,metadata)
    List.select(this_index)
    on_item_selected(this_index)

func on_deletefile():
    List.remove_item(List.get_selected_items()[0])
    Content.set_text("")

func on_text_changed():
    var metadata = { "content":Content.get_text(), "filename":List.get_item_text(List.get_selected_items()[0]) }
    List.set_item_metadata(List.get_selected_items()[0],metadata)

func on_commit():
    var files : Dictionary
    
    for item in range(0,List.get_item_count()):
        if List.get_item_metadata(item).content != "":
            files[List.get_item_metadata(item).filename] = {"content":List.get_item_metadata(item).content}
        else:
            files[List.get_item_metadata(item).filename] = {"content":"null"}
    
    
    if gist_mode == GIST_MODE.CREATING:
        var body : Dictionary = {
            "description": description,
            "public": !privacy,
            "files": files,
        }
        requesting = REQUESTS.COMMIT
        request.request("https://api.github.com/gists",UserData.header,false,HTTPClient.METHOD_POST,JSON.print(body))
        get_parent().print_debug_message("committing new gist...")
        yield(self,"gist_committed")
        close_editor()
    elif gist_mode == GIST_MODE.EDITING:
        var body : Dictionary = {
            "description": description,
            "files": files,
        }
        requesting = REQUESTS.UP_GISTS
        request.request("https://api.github.com/gists/"+gistid,UserData.header,false,HTTPClient.METHOD_PATCH,JSON.print(body))
        get_parent().print_debug_message("updating this gist...")
        get_parent().loading(true)
        yield(self,"gist_updated")
        get_parent().loading(false)
        close_editor()

func _on_Readonly_toggled(button_pressed):
    if gist_mode == GIST_MODE.CREATING:
        if button_pressed:
            Readonly.set_text("Read Only")
            Content.set_readonly(true)
        else:
            Readonly.set_text("Can Edit")
            Content.set_readonly(false)
    else:
        if button_pressed:
            Readonly.set_text("Read Only")
            Content.set_readonly(true)
            ListBar.hide()
            gist_mode = GIST_MODE.GETTING
            commit_btn.hide()
            edit_description.hide()
            if edit_description.get_node("gist_editdescription").get_text()!="":
                description = edit_description.get_node("gist_editdescription").get_text()
                GistDescription.set_text(description)
                GistDescription.show()
        else:
            Readonly.set_text("Can Edit")
            Content.set_readonly(false)
            ListBar.show()
            gist_mode = GIST_MODE.EDITING
            commit_btn.show()
            edit_description.show()
            GistDescription.hide()
            if GistDescription.get_text()!="<no description>":
                edit_description.get_node("gist_editdescription").set_text(GistDescription.get_text())

func on_delete():
    requesting = REQUESTS.DELETE
    request.request("https://api.github.com/gists/"+gistid,UserData.header,false,HTTPClient.METHOD_DELETE)
    get_parent().print_debug_message("deleting this gist...")
    yield(self,"gist_deleted")
    close_editor()

func color_region(filextension : String):
    match(filextension):
        "bbs":
            Content.add_color_region("[b]","[/b]",Color8(153,153,255,255),false)
            Content.add_color_region("[i]","[/i]",Color8(153,255,153,255),false)
            Content.add_color_region("[s]","[/s]",Color8(255,153,153,255),false)
            Content.add_color_region("[u]","[/u]",Color8(255,255,102,255),false)
            Content.add_color_region("[url","[/url]",Color8(153,204,255,255),false)
            Content.add_color_region("[code]","[/code]",Color8(192,192,192,255),false)
            Content.add_color_region("[img]","[/img]",Color8(255,204,153,255),false)
            Content.add_color_region("[center]","[/center]",Color8(175,238,238,255),false)
            Content.add_color_region("[right]","[/right]",Color8(135,206,235,255),false)
        "html":
            Content.add_color_region("<b>","</b>",Color8(153,153,255,255),false)
            Content.add_color_region("<i>","</i>",Color8(153,255,153,255),false)
            Content.add_color_region("<del>","</del>",Color8(255,153,153,255),false)
            Content.add_color_region("<ins>","</ins>",Color8(255,255,102,255),false)
            Content.add_color_region("<a","</a>",Color8(153,204,255,255),false)
            Content.add_color_region("<img","/>",Color8(255,204,153,255),true)
            Content.add_color_region("<pre>","</pre>",Color8(192,192,192,255),false)
            Content.add_color_region("<center>","</center>",Color8(175,238,238,255),false)
            Content.add_color_region("<right>","</right>",Color8(135,206,235,255),false)
        "md":
            Content.add_color_region("***","***",Color8(126,186,181,255),false)
            Content.add_color_region("**","**",Color8(153,153,255,255),false)
            Content.add_color_region("*","*",Color8(153,255,153,255),false)
            Content.add_color_region("+ ","",Color8(255,178,102,255),false)
            Content.add_color_region("- ","",Color8(255,178,102,255),false)
            Content.add_color_region("~~","~~",Color8(255,153,153,255),false)
            Content.add_color_region("__","__",Color8(255,255,102,255),false)
            Content.add_color_region("[",")",Color8(153,204,255,255),false)
            Content.add_color_region("`","`",Color8(192,192,192,255),false)
            Content.add_color_region('"*.','"',Color8(255,255,255,255),true)
            Content.add_color_region("# ","",Color8(105,105,105,255),true)
            Content.add_color_region("## ","",Color8(128,128,128,255),true)
            Content.add_color_region("### ","",Color8(169,169,169,255),true)
            Content.add_color_region("#### ","",Color8(192,192,192,255),true)
            Content.add_color_region("##### ","",Color8(211,211,211,255),true)
            Content.add_color_region("###### ","",Color8(255,255,255,255),true)
            Content.add_color_region("> ","",Color8(172,138,79,255),true)
        "cfg":
            Content.add_color_region("[","]",Color8(153,204,255,255),false)
            Content.add_color_region('"','"',Color8(255,255,102,255),false)
            Content.add_color_region(';','',Color8(128,128,128,255),true)
        "ini":
            Content.add_color_region("[","]",Color8(153,204,255,255),false)
            Content.add_color_region('"','"',Color8(255,255,102,255),false)
            Content.add_color_region(';','',Color8(128,128,128,255),true)
        _:
            pass

