class_name Boot extends Node2D


func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	Signals.load_scene.emit(&"main_menu_2d", false, false)
	queue_free()
