class_name EnemyManager extends Node2D


@export var enemies:Array[EnemyData] = []

var active_enemies:Array[EnemyData] = []

@onready var enemy_tilemap: TileMapLayer = %enemy_tilemap


func _ready() -> void:
	Signals.map_ready.connect(_spawn_enemies)


func _spawn_enemies() -> void:
	var level:int = GM.get_spawn_level()
	var count:int = GM.map_generator.room_count
	var floors = GM.map_generator.get_only_floor()

	for i in count:
		var new_enemy:EnemyData = enemies.pick_random().duplicate()
		new_enemy.level = level
		var coords = floors.keys()
		new_enemy.coords = coords.pick_random()
		while _enemy_already_there(new_enemy.coords):
			new_enemy.coords = coords.pick_random()

		var astar_grid = AStarGrid2D.new()
		astar_grid.size = MapGenerator.GRIDSIZE
		astar_grid.cell_size = Vector2(MapGenerator.TILESIZE, MapGenerator.TILESIZE)
		astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		astar_grid.jumping_enabled = false
		astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
		astar_grid.update()
		_set_points_solid(astar_grid, floors, _get_grid())
		new_enemy.astar = astar_grid

		new_enemy.setup_entity_data()
		active_enemies.append(new_enemy)
		enemy_tilemap.set_cell(new_enemy.coords, 0, new_enemy.atlas_coords)


func _character_action_taken() -> void:
	for each in active_enemies:
		var previous_coords := each.coords
		var result := each.move_enemy()
		match result:
			&"attack":
				each.attack_character()
			_:
				enemy_tilemap.erase_cell(previous_coords)
				enemy_tilemap.set_cell(each.coords, 0, each.atlas_coords)



func _enemy_already_there(coords:Vector2i) -> bool:
	for each in active_enemies:
		if each.coords == coords: return true
	return false



func _set_points_solid(astar:AStarGrid2D, _floor:Dictionary, _grid:Array[Vector2i]) -> void:
	for each in _grid:
		if not _floor.has(each):
			astar.set_point_solid(each, true)


func _get_grid() -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	for x in MapGenerator.GRIDSIZE.x:
		for y in MapGenerator.GRIDSIZE.y:
			result.append(Vector2i(x, y))
	return result