class_name HpEffectData extends EffectData


@export var flat_hp_amount := 0
@export var percent_hp_amount := 0.0


func apply_effect(target:Node2D) -> void:
	if trigger_count == 0:
		_add_hp(target)
		effect_ended = true


func update_from_action_trigger(target:Node2D) -> void:
	if effect_ended: return
	if target is Character:
		_total_triggers += 1
		if _total_triggers >= trigger_count: effect_ended = true
		_cycle_count += 1
		if _cycle_count >= delay_count:
			_cycle_count = 0
			_add_hp(target)


func _add_hp(target:Node2D) -> void:
	if target is Character:
		if flat_hp_amount != 0: 
			GM.run_selected_character.update_hp(flat_hp_amount)
			return
		GM.run_selected_character.update_hp(roundi(percent_hp_amount * GM.run_selected_character.hp))