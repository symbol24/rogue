class_name CharacterSelect extends RidControl


@onready var ridsb_select_character: RidSignalButton = %ridsb_select_character


func toggle_rid_control(display:bool) -> void:
	if display:
		ridsb_select_character.grab_focus()
		show()
	else:
		hide()
