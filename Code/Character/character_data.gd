class_name CharacterData extends EntityData


const CRITCHANCE := 0.1
const CRITBONUS := 2


var current_class:String
var current_pos:Vector2i

# Inventory
var inventory:Array[ItemData] = []
var known_items:Dictionary = {}
var coins:int
var xp := 0

# Biome
var biome:Biome.Identity
var biome_level := 0


func setup_entity_data(_spawn_level:int = 1) -> void:
	level = 1
	xp = 0
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


func _unequip(equipment_type:StringName) -> void:
	for each in inventory:
		if not each is GearData: continue
		var gear:GearData = each
		if equipment_type == GearData.Equipment_Type.keys()[gear.equipment_type] and each.equipped:
			gear.unequip()


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
	Signals.stats_updates_on_character.emit()


func _calculate_stat(stat:StringName) -> Variant:
	var value = 0.0
	if get(&"starting_"+stat) != null: value = get(&"starting_"+stat)
	for each in inventory:
		if each is GearData and each.equipped:
			if each.get(&"bonus_"+stat) != null: value += each.get(&"bonus_"+stat)
			elif each.get(&"dex_penalty") != null: value += each.get(&"dex_penalty")
	return value if stat == &"dex" else int(value)


func add_xp(value:int = 0) -> void:
	xp += value
