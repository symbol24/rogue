class_name CharacterInputProcess extends InputProcess


var _character:Character = null:
	get:
		if _character == null: _character = get_parent() as Character
		return _character


func process_input(_delta:float, event:InputEvent) -> void:
	if event == null: return
	if event.is_action_released(&"up") or event.is_action_released(&"down") or event.is_action_released(&"left") or event.is_action_released(&"right"):
		_move(event)


func _move(event:InputEvent) -> void:
	var direction := &""
	if event.is_action_released(&"up"):
		direction = &"up"
	elif event.is_action_released(&"down"):
		direction = &"down"
	elif event.is_action_released(&"left"):
		direction = &"left"
	elif event.is_action_released(&"right"):
		direction = &"right"
	
	if direction != &"": _character.move_character(direction)
