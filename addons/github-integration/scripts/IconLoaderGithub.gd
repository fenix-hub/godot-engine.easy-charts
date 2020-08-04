tool
extends Node

func _ready():
    pass

func load_icon_from_name(icon_name : String) -> ImageTexture:
    var file = File.new()
    var image = Image.new()
    var texture = ImageTexture.new()
    
    file.open("res://addons/github-integration/icons.pngs/"+icon_name+".png.iconpng", File.READ)
    var buffer = file.get_buffer(file.get_len())
    file.close()
    
    image.load_png_from_buffer(buffer)
    texture.create_from_image(image)
    return texture
