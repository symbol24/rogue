extends Node

# Debug
signal generate_test_map(room_count:int, origin:Vector2, end:Vector2)

# Scene Loader
signal load_scene(id:StringName, display_loading_screen:bool, extra_time:bool)

# Spawn Manager
signal spawn_character()
signal remove_character()

# Map Generator
signal map_ready()
signal generate_map(room_count:int, origin:Vector2, end:Vector2)
signal set_items(items:Array[ItemData])
signal remove_item(item_data:ItemData)

# UI
signal button(id:StringName)
signal toggle_loading_screen(display:bool)
signal toggle_rid_control(id:StringName, display:bool, previous:StringName)

# Inputs
signal input_mode_changed
signal input_focuse_changed

# Character
signal character_ready
signal pickup_item(item_data:ItemData)
