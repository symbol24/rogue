extends Node


enum {MOUSEANDKEYBOARD, XBOX, PS5, PS4, PS3, SWITCH}


var input_type := MOUSEANDKEYBOARD
var _input_processes:Array[InputProcess] = []
var _input_buffer:Array[InputEvent] = []
var _process_inputs := false


func _input(event: InputEvent) -> void:
	if input_type != MOUSEANDKEYBOARD and (event is InputEventKey or event is InputEventMouseButton):
		_switch_to_kbm.call_deferred()
	if input_type != XBOX and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		_switch_to_xbox.call_deferred()

	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_input_buffer.append(event)


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.input_change_focus.connect(_toggle_input_focus)
	_process_inputs = true


func _process(delta: float) -> void:
	_process_input(delta)


func register_process(input_process:InputProcess) -> void:
	_clear_invalid_processes()
	if _input_processes.has(input_process) or _check_is_already_registered(input_process): return
	_input_processes.append(input_process)


func unregister_input_process(input_process:InputProcess) -> void:
	if not _input_processes.has(input_process): return
	_input_processes.append(input_process)
	_clear_invalid_processes()


func _process_input(delta:float) -> void:
	if not _process_inputs or _input_processes.is_empty(): return
	var event:InputEvent = _input_buffer.pop_front()
	for each in _input_processes:
		if is_instance_valid(each):
			each.process_input(delta, event)


func _toggle_input_focus(id:StringName, is_focused:bool) -> void:
	_clear_invalid_processes()
	for each in _input_processes:
		if is_instance_valid(each):
			if is_focused: each.toggle_focus(false)
			if each.id == id: each.toggle_focus(is_focused)


func _toggle_focus_on_input_processes() -> void:
	_clear_invalid_processes()
	for each in _input_processes:
		if is_instance_valid(each): each.toggle_focus(false)

	_input_processes[-1].toggle_focus(true)


func _switch_to_kbm() -> void:
	input_type = MOUSEANDKEYBOARD
	Signals.input_mode_changed.emit()


func _switch_to_xbox() -> void:
	input_type = XBOX
	Signals.input_mode_changed.emit()


func _clear_invalid_processes() -> void:
	var ids:Array[int] = []
	var i := 0
	for each in _input_processes:
		if not is_instance_valid(each):
			ids.append(i)
		i += 1

	for id in ids:
		_input_processes.erase(null)


func _check_is_already_registered(process:InputProcess) -> bool:
	for each in _input_processes:
		if is_instance_valid(each):
			if process.name == each.name: return true
	return false
