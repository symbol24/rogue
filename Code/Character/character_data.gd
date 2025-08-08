class_name CharacterData extends Resource


@export var id := &""
@export var uid := ""

# Stats
@export var starting_hp := 10
@export var starting_armor := 0
@export var starting_physical_power := 1
@export var starting_mp := 0
@export var starting_magical_power := 1
@export var starting_lives := 1

# Current Stats
var level := 1
var xp := 0
var hp:int
var max_hp:int
var armor:int
var physical_power:int
var mp:int
var max_mp:int
var magical_power:int
var lives:int
var current_class:String

# Inventory
var inventory:Array[ItemData] = []
var known_items:Dictionary = {}
var coins:int

# Biome
var biome:Biome.Identity
var biome_level := 0


func setup_character_data() -> void:
	level = 1
	xp = 0
	hp = starting_hp
	max_hp = starting_hp
	armor = starting_armor
	mp = starting_mp
	max_mp = starting_mp
	magical_power = starting_magical_power
	lives = starting_lives
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
	hp = max_hp if hp + value >= max_hp else hp + value
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


