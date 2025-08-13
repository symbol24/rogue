class_name Enemy extends Node2D


var data:EnemyData
var astar_grid = AStarGrid2D.new()


func _ready() -> void:
	Signals.action_tick.connect(_action_tick)


func setup_astar(walkable:Dictionary) -> void:
	astar_grid.region = Rect2i(Vector2i.ZERO, MapGenerator.GRIDSIZE)
	astar_grid.cell_size = Vector2(1,1)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.jumping_enabled = false
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.update()
	_set_points_solid(astar_grid, walkable, _get_grid())


func _action_tick() -> void:
	if data.current_state == EnemyData.State.IDLE:
		if data.enemy_type == EnemyData.Type.AGRESSIVE: data.current_state = EnemyData.State.MOVING
	
	elif data.current_state == EnemyData.State.MOVING:
		if data.coords.distance_squared_to(GM.run_selected_character.current_pos) == 1:
			data.current_state = EnemyData.State.ATTACKING
		else:
			_move()

	elif data.current_state == EnemyData.State.ATTACKING:
		if data.coords.distance_squared_to(GM.run_selected_character.current_pos) > 1:
			data.current_state = EnemyData.State.MOVING
		else:
			_attack()


func _move() -> void:
	var path := astar_grid.get_point_path(data.coords, GM.run_selected_character.current_pos)
	if not path.is_empty():
		var next = path[1]
		var previous := data.coords
		data.coords = next
		global_position = data.coords * MapGenerator.TILESIZE
		GM.map_generator.map[previous] = data.ground_on
		var ground:int = GM.map_generator.map[data.coords]
		GM.map_generator.map[data.coords] = MapGenerator.ENEMY
		data.ground_on = ground


func _attack() -> void:
	var attack:Dictionary = data.get_attack_effect()
	if attack.has(&"success"):
		Signals.add_effect_to_target.emit(GM.spawn_manager.active_character, attack[&"success"])
		Signals.display_message.emit("%s swung and hit you." % data.display_name)
	else:
		Signals.display_message.emit("%s swung and missed." % data.display_name)


func _set_points_solid(astar:AStarGrid2D, walkable:Dictionary, _grid:Array[Vector2i]) -> void:
	for each in _grid:
		if not walkable.has(each):
			astar.set_point_solid(each, true)


func _get_grid() -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	for x in MapGenerator.GRIDSIZE.x:
		for y in MapGenerator.GRIDSIZE.y:
			result.append(Vector2i(x, y))
	return result
