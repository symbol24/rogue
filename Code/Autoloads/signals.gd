extends Node


# Debug
signal generate_test_map(room_count:int, origin:Vector2, end:Vector2)

# Scene Loader
signal load_scene(id:StringName, display_loading_screen:bool, extra_time:bool)

# Spawn Manager
signal spawn_character
signal remove_character

# Map Generator
signal map_ready
signal generate_map(room_count:int, origin:Vector2, end:Vector2)
signal set_items(items:Array[ItemData])
signal remove_item(item_data:ItemData)

# UI
signal button(id:StringName)
signal toggle_loading_screen(display:bool)
signal toggle_rid_control(id:StringName, display:bool, previous:StringName)
signal display_message(message:String)
signal inventory_item_changed(item_data:ItemData)
signal consume_button_pressed
signal equip_button_pressed
signal move_selection_up_down(target:StringName, is_up:bool)

# Inputs
signal input_mode_changed
signal input_focuse_changed
signal input_change_focus(id:StringName, focus:bool)

# Entities
signal entity_dead(entity:EntityData)

# Character
signal character_ready
signal pickup_item(item_data:ItemData)
signal consume_item(comsumable_data:ConsumableData)
signal equip_gear(gear_data:GearData)
signal update_character_hp
signal item_consumed(item_data:ItemData)
signal action_tick
signal gear_updated
signal stats_updates_on_character
signal gain_experience(value:int)
signal character_level_updated
signal character_xp_updated

# Effects
signal add_effect_to_target(target:Node2D, effect:EffectData)

# biome
signal biome_tick_counter_ticked
