class_name Effect extends Node


const POSTAPPLYDELAY := 0.1


func apply_effect(_parent:Node2D, _data:EffectData) -> void:
	assert(_parent != null and _data != null, "Missing parent or data from apply effect")
	await get_tree().create_timer(POSTAPPLYDELAY).timeout
	queue_free()