class_name EffectData extends Resource


@export var effect_uid := ""
@export var delay_count := 0
@export var trigger_count := 0
var _total_triggers := 0
var _cycle_count := 0
var effect_ended := false


func apply_effect(_target:Node2D) -> void:
	pass


func update_from_action_trigger(_target:Node2D) -> void:
	pass