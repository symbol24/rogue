class_name MainMenuNode2D extends Node2D


func _ready() -> void:
	Signals.toggle_rid_control.emit(&"main_menu", true, &"")
