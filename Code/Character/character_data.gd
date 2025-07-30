class_name CharacterData extends Resource


@export var id := &""

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


func go_to_next_biome_level() -> void:
	biome_level += 1
	if biome_level > SceneLoader.current_level.level_count:
		biome += 1
		biome_level = 0
