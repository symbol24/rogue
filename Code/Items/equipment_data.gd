class_name GearData extends ItemData


enum Equipment_Type {HELMET, CHEST, WAIST, GLOVES, BOOTS, WEAPON}


@export var equipment_type:Equipment_Type
@export var level:int
@export var bonus_armor:int
@export var bonus_hp:int
@export var bonus_mp:int
@export var bonus_physical_power:int
@export var bonus_magic_power:int
@export var bonus_lives:int
@export var dex_penalty:float

var equipped:bool = false


func get_stat(variable:StringName) -> Variant:
	if get(variable) != null: return get(variable)
	return 0


func equip() -> void:
	equipped = true


func unequip() -> void:
	equipped = false
