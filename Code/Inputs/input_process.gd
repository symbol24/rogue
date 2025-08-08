class_name InputProcess extends Node


var id := &""
var has_focus := false
var _can_defocus := true


func process_input(_delta:float, _event:InputEvent) -> void:
	pass


func toggle_focus(value:bool) -> void:
	if value: has_focus = value
	elif _can_defocus and not value: has_focus = value
	Signals.input_focuse_changed.emit()


func register() -> void:
	InputManager.register_process(self)


func unregister() -> void:
	InputManager.unregister_input_process(self)
