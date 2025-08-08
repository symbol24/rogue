class_name PauseMenuInputProcess extends InputProcess


func _ready() -> void:
	id = &"pause_menu"
	has_focus = false


func process_input(_delta:float, event:InputEvent) -> void:
	if event == null: return
	if has_focus:
		if event.is_action_pressed(&"pause"):
			_toggle_pause_menu()
		elif event.is_action_pressed(&"consume"):
			Signals.consume_button_pressed.emit()
		elif event.is_action_pressed(&"equip"):
			Signals.equip_button_pressed.emit()
		elif event.is_action_pressed(&"up"):
			Signals.move_selection_up_down.emit(&"pause_menu", true)
		elif event.is_action_pressed(&"down"):
			Signals.move_selection_up_down.emit(&"pause_menu", false)
	else:
		if event.is_action_pressed(&"pause"):
			_toggle_pause_menu()


func _toggle_pause_menu() -> void:
	if UI.is_displayed_ridControl(&"pause_menu"):
		Signals.toggle_rid_control.emit(&"in_game_ui", true, &"pause_menu")
	else:
		Signals.toggle_rid_control.emit(&"pause_menu", true, &"in_game_ui")
		Signals.input_change_focus.emit(&"pause_menu", true)
