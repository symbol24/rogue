class_name ConsumableData extends ItemData


@export var consume_count := 1
@export var effect_data:EffectData
@export var consume_message := ""

var current_count:int = -1


func setup_item() -> void:
	current_count = consume_count


func consume(target:Node2D) -> int:
	effect_data.effect_owner = GM.run_selected_character
	Signals.add_effect_to_target.emit(target, effect_data.duplicate())
	current_count -= 1
	return current_count