class_name MainMenu extends RidControl


@onready var ridsb_play: RidSignalButton = %ridsb_play


func toggle_rid_control(display:bool) -> void:
	if display:
		ridsb_play.grab_focus()
		show()
	else:
		hide()
