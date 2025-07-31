class_name LoadingScreen extends Control


const TIME := 0.5


@onready var loading_label: Label = %loading_label

var pos := 0
var max_char := 1
var timer := 0.0


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	max_char = loading_label.text.length()
	hidden.connect(_on_hide)


func _process(delta: float) -> void:
	if visible: 
		timer += delta
		if timer >= TIME:
			pos += 1
			if pos > max_char-1: pos = 0
			loading_label.visible_characters = pos
			timer = 0.0


func _on_hide() -> void:
	loading_label.visible_characters = 0
	pos = 0
