class_name ButtonManager extends Node


func _ready() -> void:
	Signals.button.connect(_manage_button)


func _manage_button(id:StringName) -> void:
	match id:
		&"generate_map":
			Signals.generate_test_map.emit(MapGenerator.SCREENSIZE)
		_:
			pass
