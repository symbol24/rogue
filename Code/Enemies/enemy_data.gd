class_name EnemyData extends EntityData


enum State {IDLE, MOVING, ATTACKING, DEAD}
enum Type {PASSIVE, AGRESSIVE}


@export var display_name := ""
@export var enemy_type := Type.PASSIVE

var coords:Vector2i
var astar:AStarGrid2D
var current_state := State.IDLE
var ground_on := 1


func get_attack_effect() -> Dictionary:
	var result := {}
	var chance := randf()
	if chance <= dex:
		var attack := HpEffectData.new()
		attack.flat_hp_amount = -physical_power if physical_power > 0 else -magical_power
		attack.effect_owner = self
		result[&"success"] = attack
	return result


func update_hp(value:int) -> void:
	if current_state != State.DEAD:
		if value < 0:
			if enemy_type == Type.PASSIVE: current_state = State.ATTACKING
			value = 0 if value - armor == 0 else value - armor
		hp = clampi(hp + value, 0, max_hp)
		if hp == 0:
			current_state = State.DEAD
			Signals.entity_dead.emit(self)