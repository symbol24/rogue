class_name EffectManager extends Node


const APPLYDELAY := 0.1


var _effect_pool:Array[EffectData] = []
var _applying := false
var _parent:Node2D = null:
	get:
		if _parent == null: _parent = get_parent() as Node2D
		return _parent


func _ready() -> void:
	Signals.add_effect_to_target.connect(_add_effect)
	Signals.action_taken.connect(_action_trigger)


func _process(_delta: float) -> void:
	if not _effect_pool.is_empty() and not _applying: _apply_effects()


func _add_effect(target:Node2D, new_effect:EffectData) -> void:
	if target == _parent:
		_effect_pool.append(new_effect.duplicate())


func _action_trigger(source:Node2D) -> void:
	if source == null or source != _parent or _effect_pool.is_empty(): return
	for each in _effect_pool: each.update_from_action_trigger(_parent)


func _apply_effects() -> void:
	if _effect_pool.is_empty(): return
	_applying = true
	for each in _effect_pool: each.apply_effect(_parent)
	_cleanup_effects()
	_applying = false


func _cleanup_effects() -> void:
	if _effect_pool.is_empty(): return
	var to_clear:Array[int] = []
	var i := 0
	for each in _effect_pool:
		if each.effect_ended:
			to_clear.append(i)
		i += 1
	if to_clear.is_empty(): return
	to_clear.reverse()
	for y in to_clear:
		var _temp = _effect_pool.pop_at(y)