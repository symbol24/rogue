class_name SpawnManager extends Node


var active_character:Character
var _biome:Biome = null:
	get:
		if _biome == null: _biome = get_parent() as Biome
		return _biome
var _items:Array[ItemData] = []
var _enemies:Array[Enemy] = []
var _enemy_spawn_count := 0


func _ready() -> void:
	process_mode = PROCESS_MODE_PAUSABLE
	Signals.spawn_character.connect(_spawn_character)
	Signals.remove_character.connect(_remove_character)
	Signals.map_ready.connect(_spawn_items_and_enemies)
	Signals.entity_dead.connect(_entity_dead)


func get_item_by_coords(coords:Vector2i) -> ItemData:
	for each in _items:
		if each.coords == coords: return each
	return null


func get_enemy_by_coords(coords:Vector2i) -> Enemy:
	for each in _enemies:
		if each.data.coords == coords: return each
	return null


func _spawn_character() -> void:
	active_character = load(GM.run_selected_character.uid).instantiate()
	add_child(active_character)
	if not active_character.is_node_ready(): await active_character.ready
	active_character.global_position = GM.map_generator.entrance*MapGenerator.TILESIZE
	active_character.setup_character(GM.map_generator.entrance)


func _remove_character() -> void:
	if is_instance_valid(active_character):
		active_character.unregister_input()
		active_character.queue_free()


func _spawn_items_and_enemies() -> void:
	_spawn_items()
	_spawn_enemies()


func _spawn_items() -> void:
	if _biome.loot_table.is_empty():
		push_warning("Biome has no _items in loot table.")
		return

	var count := randi_range(1 + SceneLoader.current_level.item_bonus_count, GM.map_generator.room_count + SceneLoader.current_level.item_bonus_count)
	for i in count:
		_items.append(_biome.loot_table.pick_random().duplicate())

	var _floor:Dictionary = GM.map_generator.get_only_floor()
	assert(not _floor.is_empty(), "Floor plan is empty, why?")
	var floor_coords := _floor.keys()
	for each in _items:
		var choice := -1
		while choice == -1:
			choice = randi_range(0, _floor.size()-1)
			if _floor[floor_coords[choice]] != MapGenerator.FLOOR: choice = -1
		
		_floor[floor_coords[choice]] = MapGenerator.ITEM
		GM.map_generator.map[floor_coords[choice]] = MapGenerator.ITEM
		
		each.coords = floor_coords[choice]
		GM.map_generator.item_layer.set_cell(each.coords, 0, each.atlas_coords)


func _spawn_enemies() -> void:
	if _biome.enemy_table.is_empty():
		push_warning("Biome has no _enemies in enemy table.")
		return
	
	var _floor:Dictionary = GM.map_generator.get_only_floor()
	var walkable:Dictionary = GM.map_generator.get_walkable()
	assert(not _floor.is_empty(), "Floor plan is empty, why?")
	for i in SceneLoader.current_level.enemies_spawned_at_start:
		var enemy_data:EnemyData = _biome.enemy_table.pick_random().duplicate()
		_enemies.append(_spawn_one_enemy(enemy_data, _floor, walkable))


func _spawn_one_random_enemy() -> void:
	var _floor:Dictionary = GM.map_generator.get_only_floor()
	var walkable:Dictionary = GM.map_generator.get_walkable()
	assert(not _floor.is_empty(), "Floor plan is empty, why?")
	var enemy_data:EnemyData = _biome.enemy_table.pick_random().duplicate()
	_enemies.append(_spawn_one_enemy(enemy_data, _floor, walkable))


func _spawn_one_enemy(enemy_data:EnemyData, _floor:Dictionary, walkable:Dictionary) -> Enemy:
	var floor_coords := _floor.keys()
	var new_enemy:Enemy = load(enemy_data.uid).instantiate()
	enemy_data.setup_entity_data(GM.get_spawn_level())
	new_enemy.data = enemy_data
	add_child(new_enemy)

	var choice := -1
	while choice == -1:
		choice = randi_range(0, _floor.size()-1)
		if _floor[floor_coords[choice]] != MapGenerator.FLOOR: choice = -1
	
	enemy_data.coords = floor_coords[choice]
	new_enemy.global_position = enemy_data.coords*MapGenerator.TILESIZE
	new_enemy.setup_astar(walkable)
	new_enemy.name = "enemy_0" + str(_enemy_spawn_count)
	_enemy_spawn_count += 1
	GM.map_generator.map[floor_coords[choice]] = MapGenerator.ENEMY

	return new_enemy


func _entity_dead(entity_data:EntityData) -> void:
	if entity_data is EnemyData:
		Signals.display_message.emit("Defeated %s" % entity_data.display_name)
		Signals.gain_experience.emit(entity_data.exp_value)
		var enemy_coords:Vector2i = entity_data.coords
		GM.map_generator.map[enemy_coords] = MapGenerator.FLOOR
		var enemy:Enemy = get_enemy_by_coords(enemy_coords)
		remove_child(enemy)
		enemy.queue_free()
		_enemies = _clean_nulls(_enemies)


func _clean_nulls(array:Array) -> Array:
	var pos:Array[int] = []
	for i in array.size()-1:
		if not is_instance_valid(array[i]): 
			pos.append(i)
	pos.reverse()
	for i in pos:
		array.remove_at(i)
	return array
