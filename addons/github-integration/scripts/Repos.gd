tool
extends Tree

signal moved(item, to_item, shift)


func get_drag_data(position): # begin drag
    set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)
    
    var preview = Label.new()
    preview.text = get_selected().get_text(0)
    set_drag_preview(preview) # not necessary
    
    return get_selected() # TreeItem


func can_drop_data(position, data):
    return data is TreeItem # you shall not pass!


func drop_data(position, item): # end drag
    var to_item = get_item_at_position(position)
    var shift = get_drop_section_at_position(position)
    # shift == 0 if dropping on item, -1, +1 if in between
    
    emit_signal('moved', item, to_item, shift)
