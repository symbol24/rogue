class_name ItemData extends Resource


enum Type {COINS, CONSUMABLE, GEAR}


@export var id := &""
@export var atlas_coords:Vector2i
@export var count := 1
@export var type:Type
@export var unknown_description := ""
@export var known_description := ""

var coords := Vector2i.ZERO


func get_description(known_ids:Dictionary) -> String:
	if known_ids.has(id) and known_ids[id] == true:
		return known_description
	return unknown_description


func get_count() -> int:
	if type == Type.COINS:
		return randi_range(0+count, 3+count)
	return count
