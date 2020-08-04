# ----------------------------------------------
#            ~{ GitHub Integration }~
# [Author] Nicolò "fenix" Santilio
# [github] fenix-hub/godot-engine.github-integration
# [version] 0.2.9
# [date] 09.13.2019





# -----------------------------------------------

tool
extends Control

onready var repo_icon = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/repo_icon
onready var private_icon = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/private_icon
onready var watch_icon = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/watch_values/watch_icon
onready var star_icon = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/star_values/star_icon
onready var fork_icon = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/fork_values/fork_icon
onready var forked_icon = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/forked_icon

onready var extension_option = $extension_choosing/VBoxContainer/extension_option
onready var extension_choosing = $extension_choosing
onready var watch_value = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/watch_values/watch
onready var star_value = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/star_values/star
onready var fork_value = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/fork_values/fork

onready var owner_ = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/repo_owner
onready var description_ = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/description
onready var default_branch_ = $Repository/BranchInfo/branch/HBoxContainer6/default_branch
onready var repo_name_ = $Repository/RepoInfos/RepoInfosContainer/RepoInfos/repo_infos/repo_name
onready var contents_ = $Repository/contents
onready var closeButton = $Repository/RepoInfos/RepoInfosContainer/close
onready var branches_ = $Repository/BranchInfo/branch/branch2
onready var DeleteRepo = $Repository/repos_buttons/HBoxContainer2/delete
onready var Commit = $Repository/repos_buttons/HBoxContainer3/commit
onready var DeleteRes = $Repository/repos_buttons/HBoxContainer2/delete2

onready var reload = $Repository/repos_buttons/HBoxContainer/reload
onready var new_branchBtn = $Repository/BranchInfo/branch/new_branchBtn
onready var newBranch = $NewBranch
onready var pull_btn = $Repository/BranchInfo/branch/pull_btn
onready var git_lfs = $Repository/BranchInfo/branch/git_lfs

onready var branch3 = $NewBranch/VBoxContainer/HBoxContainer2/branch3

onready var ExtractionRequest = $extraction_request
onready var ExtractionOverwriting = $extraction_overwriting

onready var SetupDialog = $setup_git_lfs
onready var WhatIsDialog = $whatis_dialog

onready var ExtensionsList = $setup_git_lfs/VBoxContainer/extensions_list

enum REQUESTS { REPOS = 0, GISTS = 1, UP_REPOS = 2, UP_GISTS = 3, DELETE = 4, COMMIT = 5, BRANCHES = 6, CONTENTS = 7, TREES = 8, DELETE_RESOURCE = 9, END = -1 , FILE_CONTENT = 10 ,NEW_BRANCH = 11 , PULLING = 12}
var requesting

var html : String
var request = HTTPRequest.new()
var current_repo
var current_branch
var branches = []
var branches_contents = []
var contents = [] # [0] = name ; [1] = sha ; [2] = path
var dirs = []
var item_repo : TreeItem

var commit_sha = ""
var tree_sha = ""

var multi_selected = []
var gitignore_file : Dictionary

var zip_filepath : String = ""
var archive_extension : String = ""

signal get_branches()
signal get_contents()
signal get_branches_contents()
signal loaded_repo()
signal resource_deleted()
signal new_branch_created()
signal zip_pulled()

func _ready():
    branch3.clear()
    DeleteRes.disabled = true
    DeleteRes.connect("pressed",self,"delete_resource")
    repo_name_.connect("pressed",self,"open_html")
    closeButton.connect("pressed",self,"close_tab")
    DeleteRepo.connect("pressed",self,"delete_repo")
    Commit.connect("pressed",self,"commit")
    add_child(request)
    request.connect("request_completed",self,"request_completed")
    new_branchBtn.connect("pressed",self,"on_newbranch_pressed")
    newBranch.connect("confirmed",self,"on_newbranch_confirmed")
    pull_btn.connect("pressed",self,"on_pull_pressed")
    git_lfs.connect("pressed",self,"setup_git_lfs")

func set_darkmode(darkmode : bool):
    if darkmode:
        $BG.color = "#24292e"
        set_theme(load("res://addons/github-integration/resources/themes/GitHubTheme-Dark.tres"))
        $Repository/RepoInfos.set("custom_styles/panel",load("res://addons/github-integration/resources/styles/Repohead-black.tres"))
        $Repository/BranchInfo.set("custom_styles/panel",load("res://addons/github-integration/resources/styles/Branch-black.tres"))
        $Repository/contents.set("custom_styles/bg", load("res://addons/github-integration/resources/styles/ContentesBG-dark.tres"))   
    else:
        $BG.color = "#f6f8fa"
        set_theme(load("res://addons/github-integration/resources/themes/GitHubTheme.tres"))
        $Repository/RepoInfos.set("custom_styles/panel",load("res://addons/github-integration/resources/styles/Repohead-white.tres"))
        $Repository/BranchInfo.set("custom_styles/panel",load("res://addons/github-integration/resources/styles/Branch-white.tres"))
        $Repository/contents.set("custom_styles/bg", load("res://addons/github-integration/resources/styles/ContentesBG-white.tres"))

func load_icons(r):
    repo_icon.set_texture(IconLoaderGithub.load_icon_from_name("repos"))
    if r.private:
        private_icon.set_texture(IconLoaderGithub.load_icon_from_name("lock"))
    if r.fork:
        forked_icon.set_texture(IconLoaderGithub.load_icon_from_name("forks"))
    watch_icon.set_texture(IconLoaderGithub.load_icon_from_name("watch"))
    star_icon.set_texture(IconLoaderGithub.load_icon_from_name("stars"))
    fork_icon.set_texture(IconLoaderGithub.load_icon_from_name("forks"))
    reload.set_button_icon(IconLoaderGithub.load_icon_from_name("reload-gray"))
    new_branchBtn.set_button_icon(IconLoaderGithub.load_icon_from_name("add-gray"))
    pull_btn.set_button_icon(IconLoaderGithub.load_icon_from_name("download-gray"))
    git_lfs.set_button_icon(IconLoaderGithub.load_icon_from_name("git_lfs-gray"))

func open_repo(repo : Dictionary):
    contents_.clear()
    branches_.clear()
    branches.clear()
    contents.clear()

    var r = repo
    current_repo = r
    html = r.html_url
    owner_.text = r.owner.login
    repo_name_.text = r.name
    if r.description !=null:
        description_.text = (r.description)
    else:
        description_.text = ""
    default_branch_.text = str(r.default_branch)

#	watch_value.set_text(str(r.subscribers_count))
    star_value.set_text(str(r.stargazers_count))
    fork_value.set_text(str(r.forks_count))

    load_icons(r)
    request_branches(r.name)
    
    yield(self,"loaded_repo")
    request.cancel_request()
    request_file_content(".gitignore")


func request_branches(rep : String):
    branches_.clear()
    branch3.clear()
    requesting = REQUESTS.BRANCHES
    request.request("https://api.github.com/repos/"+owner_.text+"/"+rep+"/branches",UserData.header,false,HTTPClient.METHOD_GET,"")
    yield(self,"get_branches")

    if branches.size() > 0:
        requesting = REQUESTS.TREES
        for b in branches:
            request.request("https://api.github.com/repos/"+owner_.text+"/"+rep+"/branches/"+b.name,UserData.header,false,HTTPClient.METHOD_GET,"")
            yield(self,"get_branches_contents")

        var i = 0
        for branch in branches_contents:
            branches_.add_item(branch.name)
            branches_.set_item_metadata(i,branch)

            branch3.add_item(branch.name)
            branch3.set_item_metadata(i,branch)
            i+=1

        current_branch = branches_.get_item_metadata(0)

        request_contents(current_repo.name,branches_.get_item_metadata(0))
        yield(self,"get_contents")

        build_list()
    else:
        get_parent().print_debug_message("ERROR: no branches found for this repository.",1)
        get_parent().loading(false)


func request_contents(rep : String, branch):
    contents.clear()
    contents_.clear()

    requesting = REQUESTS.CONTENTS
    request.request("https://api.github.com/repos/"+owner_.text+"/"+rep+"/git/trees/"+branch.commit.commit.tree.sha+"?recursive=1",UserData.header,false,HTTPClient.METHOD_GET,"")

func open_html():
    get_parent().loading(true)
    OS.shell_open(html)
    get_parent().loading(false)

func close_tab():
    contents.clear()
    contents_.clear()
    branches_.clear()
    branches.clear()
    current_repo = ""
    current_branch = ""
    branches.clear()
    branches_contents.clear()
    contents.clear()
    dirs.clear()
    commit_sha = ""
    tree_sha = ""
    hide()
    get_parent().UserPanel.show()



func delete_repo():
    var confirm = ConfirmationDialog.new()
    confirm.dialog_text = "Do you really want to permanently delete /"+current_repo.name+" ?"
    add_child(confirm)
    confirm.rect_position = OS.get_screen_size()/2 - confirm.rect_size/2
    confirm.popup()
    confirm.connect("confirmed",self,"request_delete",[current_repo.name])

func request_delete(repo : String):
    get_parent().loading(true)
    requesting = REQUESTS.DELETE
    request.request("https://api.github.com/repos/"+owner_.text+"/"+repo,UserData.header,false,HTTPClient.METHOD_DELETE,"")

func request_delete_resource(path : String, item : TreeItem = null):
    get_parent().loading(true)
    requesting = REQUESTS.DELETE_RESOURCE

    var body

    if multi_selected.size()>0:
        body = {
            "message":"",
            "sha": multi_selected[multi_selected.find(item)].get_metadata(0).sha,
            "branch":current_branch.name
            }
    else:
        body = {
            "message":"",
            "sha": contents_.get_selected().get_metadata(0).sha,
            "branch":current_branch.name
            }

    request.request("https://api.github.com/repos/"+owner_.text+"/"+current_repo.name+"/contents/"+path,UserData.header,false,HTTPClient.METHOD_DELETE,JSON.print(body))

func commit():
    hide()
    get_parent().CommitRepo.show()
    get_parent().CommitRepo.load_branches(branches,current_repo,contents,gitignore_file)

func request_completed(result, response_code, headers, body):
    if result == 0:
        match requesting:
            REQUESTS.DELETE:
                if response_code == 204:
                    get_parent().print_debug_message("deleted repository...")
                    OS.delay_msec(1500)
                    get_parent().UserPanel.request_repositories(REQUESTS.UP_REPOS)
                    close_tab()
                    get_parent().loading(false)
            REQUESTS.BRANCHES:
                if response_code == 200:
                    branches = JSON.parse(body.get_string_from_utf8()).result
                    emit_signal("get_branches")
            REQUESTS.CONTENTS:
                if response_code == 200:
                    contents = JSON.parse(body.get_string_from_utf8()).result.tree
                    emit_signal("get_contents")
            REQUESTS.TREES:
                if response_code == 200:
                    branches_contents.append(JSON.parse(body.get_string_from_utf8()).result)
                    emit_signal("get_branches_contents")
            REQUESTS.FILE_CONTENT:
                if response_code == 200:
                    gitignore_file = JSON.parse(body.get_string_from_utf8()).result
                    emit_signal("get_contents")
            REQUESTS.NEW_BRANCH:
                if response_code == 201:
                    get_parent().print_debug_message("new branch created!")
                    emit_signal("new_branch_created")
                    _on_reload_pressed()
                elif response_code == 422:
                    get_parent().print_debug_message("ERROR: a branch with this name already exists, try choosing another name.",1)
                    emit_signal("new_branch_created")
            REQUESTS.DELETE_RESOURCE:
                if response_code == 200:
                    get_parent().print_debug_message("deleted selected resource")
                    if multi_selected.size()>0:
                        contents.remove(0)
                    else:
                        contents.erase(contents_.get_selected().get_metadata(0))
                    emit_signal("resource_deleted")
                elif response_code == 422:
                    get_parent().print_debug_message("ERROR: can't delete a folder!",1)
                    emit_signal("resource_deleted")
            REQUESTS.PULLING:
                if response_code == 200:
                    emit_signal("zip_pulled")
    else:
        print(result," ",response_code," ",JSON.parse(body.get_string_from_utf8()).result)

func build_list():
    get_parent().loading(true)

    contents_.clear()

    var root = contents_.create_item()

    var directories : Array = []

    for content in contents:
        var content_name = content.path.get_file()
        var content_type = content.type
        if content_type == "blob":

            if content.path.get_file() == ".gitignore":
                request_file_content(content.path)
            else:
                gitignore_file = {}

            var file_dir = null

            for directory in directories:
                if directory.get_metadata(0).path == content.path.get_base_dir():
                    file_dir = directory
                    continue

            var item = contents_.create_item(file_dir)
            item.set_text(0,content_name)

            var icon
            var extension = content_name.get_extension()
            if extension == "gd":
                icon = IconLoaderGithub.load_icon_from_name("script-gray")
            elif extension == "tscn":
                icon = IconLoaderGithub.load_icon_from_name("scene-gray")
            elif extension == "png":
                icon = IconLoaderGithub.load_icon_from_name("image-gray")
            elif extension == "tres":
                icon = IconLoaderGithub.load_icon_from_name("resource-gray")
            else:
                icon = IconLoaderGithub.load_icon_from_name("file-gray")

            item.set_icon(0,icon)
            item.set_metadata(0,content)
        elif content_type == "tree":
            var dir_dir = null

            for directory in directories:
                if directory.get_metadata(0).path == content.path.get_base_dir():
                    dir_dir = directory
                    continue

            var new_dir = contents_.create_item(dir_dir)
            new_dir.set_text(0,content_name)
            new_dir.set_icon(0,IconLoaderGithub.load_icon_from_name("dir-gray"))
            new_dir.set_metadata(0,content)
            directories.append(new_dir)


            new_dir.set_collapsed(true)

    emit_signal("loaded_repo")
    get_parent().loading(false)
    show()

func request_file_content(path : String):
    requesting = REQUESTS.FILE_CONTENT
    request.request("https://api.github.com/repos/"+owner_.text+"/"+current_repo.name+"/contents/"+path+"?ref="+current_branch.name,UserData.header,false,HTTPClient.METHOD_GET)
    yield(self,"get_contents")

func _on_branch2_item_selected(ID):
    get_parent().loading(true)
    current_branch = branches_.get_item_metadata(ID)
    request_contents(current_repo.name,current_branch)
    yield(self,"get_contents")
    build_list()

func delete_resource():
    if multi_selected.size()>0:
        for item in multi_selected:
            request_delete_resource(item.get_metadata(0).path,item)
            get_parent().print_debug_message("deleting "+item.get_metadata(0).path+"...")
            yield(self,"resource_deleted")
    else:
        request_delete_resource(contents_.get_selected().get_metadata(0).path)
        get_parent().print_debug_message("deleting "+contents_.get_selected().get_metadata(0).path+"...")
        yield(self,"resource_deleted")

    multi_selected.clear()
    _on_reload_pressed()
    DeleteRes.disabled = true

func _on_contents_item_activated():
    DeleteRes.disabled = false


func _on_contents_multi_selected(item, column, selected):
    if not multi_selected.has(item):
        multi_selected.append(item)
    else:
        multi_selected.erase(item)

    DeleteRes.disabled = false

func on_newbranch_pressed():
    newBranch.get_node("VBoxContainer/HBoxContainer/name").clear()
    newBranch.popup()

func on_newbranch_confirmed():
    requesting = REQUESTS.NEW_BRANCH


    if " " in newBranch.get_node("VBoxContainer/HBoxContainer/name").get_text():
        get_parent().print_debug_message("ERROR: a branch name cannot contain spaces. Please, use '-' or '_' instead.",1)
        return

    var body = {
        "ref": "refs/heads/"+newBranch.get_node("VBoxContainer/HBoxContainer/name").get_text(),
        "sha": branch3.get_item_metadata(branch3.get_selected_id()).commit.sha
    }

    request.request("https://api.github.com/repos/"+owner_.text+"/"+current_repo.name+"/git/refs",UserData.header,false,HTTPClient.METHOD_POST,JSON.print(body))
    get_parent().print_debug_message("creating new branch...")
    yield(self,"new_branch_created")

func on_pull_pressed():
    extension_choosing.popup()

func _process(delta):
    if requesting == REQUESTS.PULLING:
        if request.get_downloaded_bytes() > 0:
            get_parent().show_number(request.get_downloaded_bytes(),"bytes downloaded")

func _on_reload_pressed():
    get_parent().loading(true)
    get_parent().print_debug_message("reloading all branches, please wait...")
    branch3.clear()
    contents.clear()
    contents_.clear()
    branches_.clear()
    branches.clear()
    current_branch = ""
    branches.clear()
    branches_contents.clear()
    contents.clear()
    dirs.clear()
    commit_sha = ""
    tree_sha = ""
    open_repo(current_repo)

#func gdscript_extraction():
#    var archive = unzipper._load(zip_filepath)
#
#    if archive:
#        var root : String = unzipper.files.values()[0].file_name
#        for file in unzipper.files.values():
#            var uncompressed = unzipper.uncompress(file.file_name)
#            if uncompressed:
#                #print("File:" +file.file_name.lstrip(root))
#                if file.file_name.lstrip(root).get_base_dir()!='':
#                    var dir : Directory = Directory.new()
#                    dir.make_dir("res://uncompressed/"+file.file_name.lstrip(root).get_base_dir())
#                    #print("Directory:" +file.file_name.lstrip(root).get_base_dir())
#                var uncompressed_file : File = File.new()
#                uncompressed_file.open("res://uncompressed/"+file.file_name.lstrip(root),File.WRITE)
#                uncompressed_file.store_string(uncompressed.get_string_from_utf8())
#                uncompressed_file.close()


func _on_extraction_overwriting_confirmed():
    pass # Replace with function body.


func _on_extension_option_item_selected(id):
    archive_extension = extension_option.get_item_text(id)

func _on_extension_choosing_confirmed():
    requesting = REQUESTS.PULLING

    var typeball : String = ""

    match archive_extension:
        ".zip":
            typeball = "zipball"
        ".tar.gz":
            typeball = "tarball"
        _:
            archive_extension = ".zip"
            typeball = "zipball"

    var zipfile = File.new()
    zip_filepath = "res://"+current_repo.name+"-"+current_branch.name+archive_extension
    zipfile.open_compressed(zip_filepath,File.WRITE,File.COMPRESSION_GZIP)
    zipfile.close()
    request.set_download_file(zip_filepath)


    var zip_url : String = current_branch._links.html.replace("tree",typeball).replace("github.com","api.github.com/repos")
    request.request(zip_url,UserData.header,false,HTTPClient.METHOD_GET)
    get_parent().loading(true)
    get_parent().print_debug_message("pulling from selected branch, a "+archive_extension+" file will automatically be created at the end of the process in 'res://' ...")
    yield(self,"zip_pulled")
    requesting = REQUESTS.END
    get_parent().print_debug_message(archive_extension+" file created with the selected branch inside, you can find it at -> "+zip_filepath)
    get_parent().loading(false)
    request.set_download_file("")

#	var extracted = ProjectSettings.load_resource_pack(current_repo.name+"-"+current_branch.name+archive_extension)
#	print(extracted)
    ExtractionRequest.popup()

func setup_git_lfs():
    var path : String = UserData.directory+current_repo.name+"/"+current_branch.name+"/.gitattributes"
    var extensions : String = ""
    if File.new().file_exists(path) :
        get_parent().print_debug_message(".gitattributes file already set for this repository. You can overwrite it.")
        var gitattributes = File.new()
        gitattributes.open(path,File.READ)
        ExtensionsList.set_text("")
        while not gitattributes.eof_reached():
            extensions += (gitattributes.get_line().split(" "))[0].replace("*","")+"\n"
        ExtensionsList.set_text(extensions)

    SetupDialog.popup()

func _on_cancel_pressed():
    ExtractionRequest.hide()

func _on_gdscript_pressed():
#    gdscript_extraction()
    pass
    
func _on_python_pressed():
    python_extraction()

func _on_java_pressed():
    java_extraction()

func python_extraction():
    var output = []
    var unzipper_path = ProjectSettings.globalize_path("res://addons/github-integration/resources/extraction/unzip.py")
    var arguments : PoolStringArray = [unzipper_path,ProjectSettings.globalize_path(zip_filepath),ProjectSettings.globalize_path("res://")]
    var err = OS.execute("python",arguments,true)
    get_parent().print_debug_message("archive unzipped in project folder with Python method.")
    ExtractionRequest.hide()

func java_extraction():
    var output = []
    var unzipper_path = ProjectSettings.globalize_path("res://addons/github-integration/resources/extraction/unzipper.jar")
    var arguments : PoolStringArray = ["-jar",unzipper_path,ProjectSettings.globalize_path(zip_filepath),ProjectSettings.globalize_path("res://")]
    var err = OS.execute("java",arguments,true)
    get_parent().print_debug_message("archive unzipped in project folder with Java method.")
    ExtractionRequest.hide()

func _on_whatis_pressed():
    WhatIsDialog.popup()

func _on_learnmore_pressed():
    OS.shell_open("https://git-lfs.github.com")

func _on_setup_git_lfs_confirmed():
    var exstensionList : Array = []
    if ExtensionsList.get_line_count() > 0 and ExtensionsList.get_line(0) != "":
        for exstension in ExtensionsList.get_line_count():
            exstensionList.append(ExtensionsList.get_line(exstension))
    setup_gitlfs(exstensionList)

func setup_gitlfs(extensions : Array):
    var gitattributes = File.new()
    var dir = Directory.new()
    var directory : String = UserData.directory+current_repo.name+"/"+current_branch.name
    if not dir.dir_exists(directory):
        dir.make_dir(directory)
    gitattributes.open(directory+"/.gitattributes",File.WRITE_READ)
    for extension in extensions:
        var tracking : String = "*."+extension+" filter=lfs diff=lfs merge=lfs -text"
        gitattributes.store_line(tracking)
    gitattributes.close()
    get_parent().print_debug_message("New .gitattributes created with the file extensions you want to track. It will be uploaded to you repository during the next push.")


