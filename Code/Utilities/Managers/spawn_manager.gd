class_name SpawnManager extends Node


var active_character:Character
var biome:Biome = null:
	get:
		if biome == null: biome = get_parent() as Biome
		return biome
var items:Array[ItemData] = []

func _ready() -> void:
	process_mode = PROCESS_MODE_PAUSABLE
	Signals.spawn_character.connect(_spawn_character)
	Signals.remove_character.connect(_remove_character)
	Signals.map_ready.connect(_spawn_items)


func get_item_by_coords(coords:Vector2i) -> ItemData:
	for each in items:
		if each.coords == coords: return each
	return null


func _spawn_character() -> void:
	active_character = load(GM.run_selected_character.uid).instantiate()
	add_child(active_character)
	if not active_character.is_node_ready(): await active_character.ready
	active_character.global_position = GM.map_generator.entrance*8
	active_character.setup_character(GM.map_generator.entrance)


func _remove_character() -> void:
	if is_instance_valid(active_character):
		active_character.unregister_input()
		active_character.queue_free()


func _spawn_items() -> void:
	if biome.loot_table.is_empty():
		push_warning("Biome has no items in loot table.")
		return

	var count := randi_range(1 + SceneLoader.current_level.item_bonus_count, GM.map_generator.rooms.size() + SceneLoader.current_level.item_bonus_count)
	for i in count:
		items.append(biome.loot_table.pick_random().duplicate())

	Signals.set_items.emit(items)
