extends Node

# Debug
signal generate_test_map(room_count:int, origin:Vector2, end:Vector2)

# Spawn Manager
signal spawn_character()
signal remove_character()

# Map Generator
signal map_ready()

# UI
signal button(id:StringName)
