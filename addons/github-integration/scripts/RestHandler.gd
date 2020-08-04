tool
extends Node

signal _check_connection(connection)
var Client : HTTPClient = HTTPClient.new()

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(false)

func check_connection() -> void:
    var connection : int = Client.connect_to_host("www.githubstatus.com")
    assert(connection == OK) # Make sure connection was OK.
    set_process(true)
    if PluginSettings.debug:
        print("[GitHub Integration] Connecting to API, please wait...")

func _process(delta):
    # Wait until resolved and connected.
    if Client.get_status() == HTTPClient.STATUS_CONNECTING or Client.get_status() == HTTPClient.STATUS_RESOLVING:
        Client.poll()
    else:
        if Client.get_status() == HTTPClient.STATUS_CONNECTED:
            if PluginSettings.debug:
                print("[GitHub Integration] Connection to API successful")
            emit_signal("_check_connection",true)
        else:
            if PluginSettings.debug:
                printerr("[GitHub Integration] Connection to API unsuccessful, exited with error %s, staus: %s" % 
            [Client.get_response_code(), Client.get_status()])
            emit_signal("_check_connection",false)
        set_process(false)
