class_name EntityData extends Resource

@export var id := &""
@export var uid := ""

# Stats
@export_category("Stats")
@export var starting_hp := 10
@export var starting_armor := 0
@export var starting_physical_power := 1
@export var starting_mp := 0
@export var starting_magical_power := 1
@export var starting_dex := 1.0
@export var starting_lives := 1
@export var starting_exp_value := 1

# Current Stats
var level := 1
var hp:int
var max_hp:int
var armor:int
var physical_power:int
var mp:int
var max_mp:int
var magical_power:int
var dex:float
var lives:int
var exp_value:int


func setup_entity_data(spawn_level:int = 1) -> void:
	level = spawn_level
	hp = starting_hp
	max_hp = starting_hp
	_calculate_all_stats()


func update_hp(value:int) -> void:
	if value < 0:
		value = 0 if value - armor == 0 else value - armor
	hp = clampi(hp + value, 0, max_hp)


func _calculate_all_stats() -> void:
	var pre_max_hp = max_hp
	var pre_hp = hp
	max_hp = _calculate_stat(&"hp")
	if pre_hp == pre_max_hp: hp = max_hp
	armor = _calculate_stat(&"armor")
	var pre_max_mp = max_mp
	var pre_mp = mp
	max_mp = _calculate_stat(&"mp")
	if pre_mp == pre_max_mp: mp = max_mp
	physical_power = _calculate_stat(&"physical_power")
	magical_power = _calculate_stat(&"magical_power")
	dex = _calculate_stat(&"dex")
	lives = _calculate_stat(&"lives")
	exp_value = _calculate_stat(&"exp_value") * level


# TODO: Need to update with level modifiers?
func _calculate_stat(stat:StringName) -> Variant:
	var value = 0.0
	if get(&"starting_"+stat) != null: value = get(&"starting_"+stat)
	return value if stat == &"dex" else int(value)
