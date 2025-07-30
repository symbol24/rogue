class_name RidControl extends Control


@export var id := &""


func toggle_rid_control(display:bool) -> void:
	if display:
		show()
	else:
		hide()
