class_name RidSignalButton extends Button


@export var id := &""


func _pressed() -> void:
	Signals.button.emit(id)
