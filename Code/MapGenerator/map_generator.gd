class_name MapGenerator extends Node


enum {MERGED_EAST, MERGED_SOUTH}
enum {WALL, FLOOR, DOOR, ENTRANCE, EXIT}


const ROOMIDS:Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8]
const TILES:TileSet = preload("uid://cq5vem7f4wkgs")
const DEBUGROOMCOUNT:int = 1
const SCREENSIZE := Vector2i(640, 320)
const ROOMRANGES := Vector2i(3, 5)
const XOFFSET := [2, 10]
const YOFFSET := [1, 5]
const ENTRANCEATLAS := Vector2i(5, 3)
const EXITATLAS := Vector2i(4, 3)


@export var proportions: Array[float] = [0.9, 1.0, 1.1]
@export var merge_chances: Array[float] = [1.0, 0.8, 0.4, 0.2, 0.0]
@export var tile_map_layer:TileMapLayer

var slices_through_x: Array[int]
var slices_through_y: Array[int]
var next_gen_id := 0
var map:Dictionary[Vector2i, int] = {}
var entrance:Vector2i

@onready var rooms: Node2D = %rooms


func _ready() -> void:
	Signals.generate_test_map.connect(_make_map)


func _make_map(dimensions: Vector2i) -> void:
	_clear_map(dimensions)

	var sliced := _slice_map(dimensions)
	var sections := _get_sections()
	var merged := _merge_slices(sliced, sections)
	var room_datas := _finalize_datas(merged)
	_display_rooms(room_datas)
	_set_entrance_and_exit()

	Signals.map_ready.emit()


func _clear_map(_dimension:Vector2i) -> void:
	map.clear()
	for child in get_children(): child.queue_free()

	for x in _dimension.x:
		for y in _dimension.y:
			map[Vector2i(x, y)] = -1

	tile_map_layer.clear()


func _slice_map(_dimension:Vector2i) -> Array[Array]:
	var sliced_x:int = _dimension.x/3
	var sliced_y:int = _dimension.y/3

	return [
		[
			[Vector2i(1, 1), Vector2i(sliced_x, sliced_y)],
			[Vector2i(sliced_x+1, 1), Vector2i(sliced_x*2, sliced_y)],
			[Vector2i((sliced_x*2)+1, 1), Vector2i((sliced_x*3), sliced_y)]
		],
		[
			[Vector2i(1, sliced_y+1), Vector2i(sliced_x, sliced_y*2)],
			[Vector2i(sliced_x+1, sliced_y+1), Vector2i(sliced_x*2, sliced_y*2)],
			[Vector2i((sliced_x*2)+1, sliced_y+1), Vector2i((sliced_x*3), sliced_y*2)]
		],
		[
			[Vector2i(1, (sliced_y*2)+1), Vector2i(sliced_x, sliced_y*3)],
			[Vector2i(sliced_x+1, (sliced_y*2)+1), Vector2i(sliced_x*2, sliced_y*3)],
			[Vector2i((sliced_x*2)+1, (sliced_y*2)+1), Vector2i((sliced_x*3), sliced_y*3)]
		],
	]


func _get_sections() -> Array[Array]:
	var room_count := randi_range(ROOMRANGES.x, ROOMRANGES.y)
	var sections:Array[Array] = [
		[null, null, null],
		[null, null, null],
		[null, null, null]
	]

	var current_room := 0
	var pos:Vector2i = Vector2i(randi_range(0,2), 0)
	while current_room < room_count:
		while sections[pos.x][pos.y] != null:
			pos = Vector2i(randi_range(0,2), randi_range(0,2))

		sections[pos.x][pos.y] = current_room

		var direction := MERGED_EAST
		if randf() < merge_chances[current_room]:
			if pos.y < 2 and (randi() == 1 or pos.x == 2): direction = MERGED_SOUTH

			if direction == MERGED_EAST and pos.x < 2: sections[pos.x+1][pos.y] = current_room
			elif direction == MERGED_SOUTH and pos.y < 2: sections[pos.x][pos.y+1] = current_room

		current_room += 1

	return sections


func _merge_slices(_map:Array[Array], _sections:Array[Array]) -> Array[Array] :
	var new_map:Array[Array] = []
	var room_coords:Dictionary = {}
	for x in _sections.size():
		for y in _sections[x].size():
			if _sections[x][y] != null:
				if room_coords.has(_sections[x][y]):
					room_coords[_sections[x][y]].append(Vector2i(x, y))
				else:
					room_coords[_sections[x][y]] = [Vector2i(x, y)]

	for key in room_coords.keys():
		var i := 0
		var first:Vector2i = Vector2i.ONE
		var last:Vector2i = Vector2i.ONE
		for coords in room_coords[key]:
			if i == 0:
				first = _map[coords.x][coords.y][0]
				last = _map[coords.x][coords.y][1]
				#print("first: ", first)
				#print("last: ", last)
			else:
				#print("_map[coords.x][coords.y][0]: ", _map[coords.x][coords.y][0])
				#print("first: ", first)
				if _map[coords.x][coords.y][0].x < first.x: first.x  = _map[coords.x][coords.y][0].x
				if _map[coords.x][coords.y][0].y < first.y: first.y  = _map[coords.x][coords.y][0].y

				#print("_map[coords.x][coords.y][1]: ", _map[coords.x][coords.y][1])
				#print("last: ", last)
				if _map[coords.x][coords.y][1].x > last.x: last.x  = _map[coords.x][coords.y][1].x
				if _map[coords.x][coords.y][1].y > last.y: last.y  = _map[coords.x][coords.y][1].y
			i += 1
		#print("Appending: ", first, " ", last)
		new_map.append([first, last])
		#print("-------------")

	return new_map


func _finalize_datas(_merged:Array[Array]) -> Array[RoomData]:
	var result:Array[RoomData] = []
	var i := 0
	for row in _merged:
		var first_x:int = (row[0].x/8) + randi_range(XOFFSET[0], XOFFSET[1])
		var first_y:int = (row[0].y/8) + randi_range(YOFFSET[0], YOFFSET[1])
		var last_x:int = (row[1].x/8) - randi_range(XOFFSET[0], XOFFSET[1])
		var last_y:int = (row[1].y/8) - randi_range(YOFFSET[0], YOFFSET[1])
		var new_rd:RoomData = RoomData.new()
		new_rd.room = [Vector2i(first_x, first_y), Vector2i(last_x, last_y)]
		new_rd.id = i
		i += 1
		result.append(new_rd)
	return result


func _display_rooms(_room_datas:Array[RoomData]) -> void:
	var all_cells:Array[Vector2i] = []

	# Walls
	for room in _room_datas:
		# Top wall
		var x := room.first_cell.x
		while x <= room.last_cell.x:
			var cell := Vector2i(x, room.first_cell.y)
			all_cells.append(cell)
			map[cell] = WALL
			x +=1
		# Bottom wall
		x = room.first_cell.x
		while x <= room.last_cell.x:
			var cell := Vector2i(x, room.last_cell.y)
			all_cells.append(Vector2i(cell))
			map[cell] = WALL
			x +=1
		# Left wall
		var y := room.first_cell.y
		while y <= room.last_cell.y:
			var cell := Vector2i(room.first_cell.x, y)
			all_cells.append(cell)
			map[cell] = WALL
			y += 1
		# Right wall
		y = room.last_cell.y
		while y <= room.last_cell.y:
			var cell := Vector2i(room.last_cell.x, y)
			all_cells.append(cell)
			map[cell] = WALL
			y += 1

	for room in _room_datas:
		var x = room.first_cell.x+1
		while x <= room.last_cell.x-1:
			var y = room.first_cell.y+1
			while y <= room.last_cell.y-1:
				var cell := Vector2i(x, y)
				all_cells.append(cell)
				map[cell] = FLOOR
				y += 1
			x += 1

	tile_map_layer.set_cells_terrain_connect(all_cells, 0, 0)


func _set_entrance_and_exit() -> void:
	var keys = map.keys()
	entrance = keys.pick_random()
	while map[entrance] != FLOOR:
		entrance = keys.pick_random()

	map[entrance] = ENTRANCE
	tile_map_layer.set_cell(entrance, 0, ENTRANCEATLAS)

	var exit:Vector2i = keys.pick_random()
	while map[exit] != FLOOR:
		exit = keys.pick_random()

	map[exit] = EXIT
	tile_map_layer.set_cell(exit, 0, EXITATLAS)
