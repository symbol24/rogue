class_name ButtonManager extends Node


func _ready() -> void:
	Signals.button.connect(_manage_button)


func _manage_button(id:StringName) -> void:
	match id:
		&"generate_map":
			Signals.generate_test_map.emit(MapGenerator.SCREENSIZE)
		&"debug_generate_map":
			Signals.remove_character.emit()
			Signals.generate_test_map.emit(MapGenerator.SCREENSIZE)
		&"main_menu":
			Signals.toggle_rid_control.emit(&"main_menu", true, &"")
		&"character_select":
			Signals.toggle_rid_control.emit(&"character_select", true, &"main_menu")
		&"character_selected":
			Signals.toggle_rid_control.emit(&"character_select", false, &"character_select")
			Signals.load_scene.emit(&"FIRST", true, true)
		_:
			pass
