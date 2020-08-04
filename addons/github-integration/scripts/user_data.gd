# ----------------------------------------------
#            ~{ GitHub Integration }~
# [Author] Nicolò "fenix" Santilio 
# [github] fenix-hub/godot-engine.github-integration
# [version] 0.2.9
# [date] 09.13.2019





# -----------------------------------------------

tool
extends Node

# saves and loads user datas from custom folder in user://github_integration/user_data.ud

var directory : String = ""
var file_name = "user_data.ud"
var avatar_name = "avatar.png"

var USER : Dictionary

# --- on the USER usage
# login = username
# avatar
# id

var AUTH : String
var AVATAR : ImageTexture
var TOKEN : String
var MAIL : String

var header : Array = [""]
var gitlfs_header : Array = [""]
var gitlfs_request : String = ".git/info/lfs/objects/batch"

var plugin_version : String = "0.9.4"

func _ready():
    directory = PluginSettings.plugin_path

func save(user : Dictionary, avatar : PoolByteArray, auth : String, token : String, mail : String) -> void:
    
    var dir = Directory.new()
    var file = File.new()
    
    if not dir.dir_exists(directory):
        dir.make_dir(directory)
        if PluginSettings.debug:
            print("[GitHub Integration] >> ","made custom directory in user folder, it is placed at ", directory)
        
    if user!=null:
        var err = file.open_encrypted_with_pass(directory+file_name,File.WRITE,OS.get_unique_id())
        USER = user
        AUTH = auth
        TOKEN = token
        MAIL = mail
        var formatting : PoolStringArray
        formatting.append(auth)                     #0
        formatting.append(mail)                     #1
        formatting.append(token)                    #2
        formatting.append(JSON.print(user))         #3
        formatting.append(plugin_version)           #4
        file.store_csv_line(formatting)
        file.close()
        if PluginSettings.debug:
            print("[GitHub Integration] >> ","saved user datas in user folder")
        
    
    save_avatar(avatar)
    
    header = ["Authorization: token "+token]

func save_avatar(avatar : PoolByteArray):
    if avatar!=null:
        var img = Image.new()
        img.load_png_from_buffer(avatar)
        img.save_png(directory+avatar_name)
        if PluginSettings.debug:
            print("[GitHub Integration] >> ","saved avatar in user folder")
        var av : Image = Image.new()
        av.load(directory+avatar_name)
        var img_text : ImageTexture = ImageTexture.new()
        img_text.create_from_image(av)
        AVATAR = img_text    

func load_user() -> PoolStringArray :
    directory = PluginSettings.plugin_path
    var file = File.new()
    var content : PoolStringArray
    
    if PluginSettings.debug:
        print("[GitHub Integration] >> loading user profile, checking for existing logfile...")
    
    if file.file_exists(directory+file_name) :
        if PluginSettings.debug:
            print("[GitHub Integration] >> ","logfile found, fetching datas..")
        file.open_encrypted_with_pass(directory+file_name,File.READ,OS.get_unique_id())
        content = file.get_csv_line()
        if content.size() < 5:
            if PluginSettings.debug:
                printerr("[GitHub Integration] >> ","this log file belongs to an older version of this plugin and will not support the mail/password login deprecation, so it will be deleted. Please, insert your credentials again.")
            file.close()
            var dir = Directory.new()
            dir.remove(directory+file_name)
            content = []
            return content
        
        AUTH = content[0]
        MAIL = content[1]
        TOKEN = content[2]
        USER = JSON.parse(content[3]).result
        load_avatar()
        
        header = ["Authorization: token "+TOKEN]
        gitlfs_header = [
            "Accept: application/vnd.git-lfs+json",
            "Content-Type: application/vnd.git-lfs+json"]
        gitlfs_header.append(header[0])
    else:
        if PluginSettings.debug:
            printerr("[GitHub Integration] >> ","no logfile found, log in for the first time to create a logfile.")
    
    return content

func load_avatar():
    var file : File = File.new()
    var av : Image = Image.new()
    var img_text : ImageTexture = ImageTexture.new()
    if file.file_exists(directory+avatar_name):    
        av.load(directory+avatar_name)
        img_text.create_from_image(av)
        AVATAR = img_text
    else:
        AVATAR = null

func delete_user():
    var dir : Directory = Directory.new()
    dir.open(directory)
    dir.remove(directory+file_name)
    dir.remove(directory+avatar_name)
    
