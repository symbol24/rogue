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
	print("Item type on pickup: ", ItemData.Type.keys()[item.type])
	if item.type == ItemData.Type.COINS: coins += item.get_count()
	else: inventory.append(item.duplicate())
	
	print("------")
	print("Coins: ", coins)
	print("Inventory:")
	if inventory.is_empty(): print("Empty")
	else:
		for each in inventory:
			print(each.get_description(known_items))
	print("------")
