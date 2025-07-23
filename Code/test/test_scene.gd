extends Node2D


@onready var generate_rooms: Button = %generate_rooms
@onready var screen_dimensions: Vector2i = MapGenerator.SCREENSIZE / 8


func _ready() -> void:
	generate_rooms.pressed.connect(_generate_rooms_pressed)


func _generate_rooms_pressed() -> void:
	Signals.remove_character.emit()
	Signals.generate_test_map.emit(MapGenerator.SCREENSIZE)
