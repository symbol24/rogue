class_name CharacterData extends EntityData


const CRITCHANCE := 0.1
const CRITBONUS := 2
const STARTINGXPPERLEVEL := 10
const LEVELXPPROGRESSION := 0.05
const STATLEVELPROGRESSION := 0.05


var current_class:String
var current_pos:Vector2i

# Inventory
var inventory:Array[ItemData] = []
var known_items:Dictionary = {}
var coins:int

# Rpogression
var xp := 0
var total_xp := 0
var current_level_xp_requirement:int = STARTINGXPPERLEVEL
var next_level_xp_requirement:int:
	get:
		return roundi(level * STARTINGXPPERLEVEL * LEVELXPPROGRESSION) + current_level_xp_requirement

# Biome
var biome:Biome.Identity
var biome_level := 0


func setup_entity_data(_spawn_level:int = 1) -> void:
	level = 1
	xp = 0
	total_xp = 0
	hp = starting_hp
	max_hp = starting_hp
	_calculate_all_stats()
	biome = Biome.Identity.FIRST
	biome_level = 0
	coins = 0
	inventory.clear()
	known_items.clear()
	current_class = "Adventurer"


func go_to_next_biome_level() -> void:
	biome_level += 1
	if biome_level > SceneLoader.current_level.level_count:
		var i = biome as int
		i += 1
		biome  = i as Biome.Identity
		biome_level = 0


func add_item_to_known(_id:StringName) -> void:
	known_items[_id] = true


func pickup(item:ItemData) -> void:
	if item.type == ItemData.Type.COINS:
		coins += item.get_count()
		Signals.display_message.emit(item.get_description(known_items) % item.get_count())
	else:
		var new:ItemData = item.duplicate()
		new.setup_item()
		inventory.append(new)
		Signals.display_message.emit("Picked up: " + item.get_description(known_items))


func update_hp(value:int) -> void:
	print("Updating hp for ", value)
	if value < 0:
		value = 0 if value - armor == 0 else value - armor
	hp = clampi(hp + value, 0, max_hp)
	Signals.update_character_hp.emit()


func remove_item(item:ItemData, amount:int = 1) -> bool:
	if item.type == ItemData.Type.COINS:
		if coins >= amount: 
			coins -= amount
			return true
	else:
		var i := 0
		var found := false
		for each in inventory:
			if each.coords == item.coords:
				found = true
				break
			i += 1
		if found:
			var _temp = inventory.pop_at(i)
			return true
	return false


func equip(equipment_data:GearData) -> void:
	var equipment_type:StringName = GearData.Equipment_Type.keys()[equipment_data.equipment_type]
	_unequip(equipment_type)
	equipment_data.equip()
	_calculate_all_stats()


func add_xp(value:int = 0) -> void:
	xp += value
	total_xp += value
	Signals.character_xp_updated.emit()
	if xp >= current_level_xp_requirement:
		xp = 0
		current_level_xp_requirement = next_level_xp_requirement
		level += 1
		_calculate_all_stats()
		Signals.character_level_updated.emit()


func _unequip(equipment_type:StringName) -> void:
	for each in inventory:
		if not each is GearData: continue
		var gear:GearData = each
		if equipment_type == GearData.Equipment_Type.keys()[gear.equipment_type] and each.equipped:
			gear.unequip()


func _calculate_all_stats() -> void:
	max_hp = _calculate_stat(&"hp") + (starting_hp * level * STATLEVELPROGRESSION)
	hp = max_hp
	armor = _calculate_stat(&"armor")
	max_mp = _calculate_stat(&"mp") + (starting_mp * level * STATLEVELPROGRESSION)
	mp = max_mp
	physical_power = _calculate_stat(&"physical_power") + (starting_physical_power * level * STATLEVELPROGRESSION)
	magical_power = _calculate_stat(&"magical_power") + (starting_magical_power * level * STATLEVELPROGRESSION)
	dex = _calculate_stat(&"dex")
	lives = _calculate_stat(&"lives")
	Signals.stats_updates_on_character.emit()


func _calculate_stat(stat:StringName) -> Variant:
	var value = 0.0
	if get(&"starting_"+stat) != null: value = get(&"starting_"+stat)
	for each in inventory:
		if each is GearData and each.equipped:
			if each.get(&"bonus_"+stat) != null: value += each.get(&"bonus_"+stat)
			elif each.get(&"dex_penalty") != null: value += each.get(&"dex_penalty")
	return value if stat == &"dex" else int(value)
