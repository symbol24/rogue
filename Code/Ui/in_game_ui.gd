class_name InGameUi extends RidControl


@onready var messages: Label = %messages
@onready var class_label: Label = %class_label
@onready var hp_label: Label = %hp_label
@onready var armor_label: Label = %armor_label
@onready var mp_label: Label = %mp_label
@onready var exp_label: Label = %exp_label
@onready var level_label: Label = %level_label


func _ready() -> void:
	Signals.display_message.connect(_display_message)
	Signals.update_character_hp.connect(_update_hp)
	Signals.stats_updates_on_character.connect(_update_stats)


func toggle_rid_control(display:bool) -> void:
	if display:
		messages.text = "Dungeon Level: World %s - %s" % [GM.run_selected_character.biome+1, GM.run_selected_character.biome_level+1]
		_update_stats()
		Signals.input_change_focus.emit(&"character_input", true)
		show()
	else:
		hide()


func _display_message(message:String) -> void:
	messages.text = message


func _update_hp() -> void:
	hp_label.text = "%s/%s" % [GM.run_selected_character.hp, GM.run_selected_character.max_hp]


func _update_stats() -> void:
	class_label.text = GM.run_selected_character.current_class
	hp_label.text = "%s/%s" % [GM.run_selected_character.hp, GM.run_selected_character.max_hp]
	armor_label.text = str(GM.run_selected_character.armor)
	mp_label.text = "%s/%s" % [GM.run_selected_character.mp, GM.run_selected_character.max_mp]
	exp_label.text = str(GM.run_selected_character.xp)
	level_label.text = str(GM.run_selected_character.level)