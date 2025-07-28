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
	process_mode = Node.PROCESS_MODE_ALWAYS
	_process_inputs = true


func _process(delta: float) -> void:
	_process_input(delta)


func register_process(input_process:InputProcess) -> void:
	if _input_processes.has(input_process): return
	_input_processes.append(input_process)
	_toggle_focus_on_input_processes()


func unregister_input_process(input_process:InputProcess) -> void:
	if not _input_processes.has(input_process): return
	_input_processes.append(input_process)


func _process_input(delta:float) -> void:
	if not _process_inputs or _input_processes.is_empty(): return
	if is_instance_valid(_input_processes[-1]):
		_input_processes[-1].process_input(delta, _input_buffer.pop_front())


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
