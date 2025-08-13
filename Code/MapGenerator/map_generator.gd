class_name MapGenerator extends Node


enum {MERGED_EAST, MERGED_SOUTH}
enum {WALL, FLOOR, DOOR, ENTRANCE, EXIT, HALLWAY, ENEMY, ITEM}


const ROOMIDS:Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8]
const MAXCONNECTIONS:Array[int] = [1, 2, 1, 2, 3, 2, 1, 2, 1]
const IDATLAS:Array[Vector2i] = [Vector2i(11, 7), Vector2i(12, 7), Vector2i(13, 7), Vector2i(11, 8), Vector2i(12, 8), Vector2i(13, 8), Vector2i(11, 9), Vector2i(12, 9), Vector2i(13, 9)]
const TILES:TileSet = preload("uid://cq5vem7f4wkgs")
const DEBUGROOMCOUNT:int = 1
const SCREENSIZE := Vector2i(640, 320)
const TILESIZE := 8
const GRIDSIZE := SCREENSIZE/TILESIZE
const ROOMRANGES := Vector2i(3, 5)
const XOFFSET := [2, 10]
const YOFFSET := [1, 5]
const ENTRANCEATLAS := Vector2i(5, 3)
const EXITATLAS := Vector2i(4, 3)
const HORDOOR := Vector2i(1, 1)
const VERTDOOR := Vector2i(4, 2)
const MAXCONNECTIONDISTANCE := 50.0
const DEBUGROOMLABEL := preload("uid://b3xunnc54t7ws")


@export var proportions: Array[float] = [0.9, 1.0, 1.1]
@export var merge_chances: Array[float] = [1.0, 0.8, 0.4, 0.2, 0.0]
@export var tile_map_layer:TileMapLayer
@export var item_layer:TileMapLayer

var map:Dictionary = {}
var entrance:Vector2i
var room_count:int:
	get:
		return _rooms.size()
var _rooms:Array[RoomData] = []


func _ready() -> void:
	Signals.generate_test_map.connect(_make_map)
	Signals.generate_map.connect(_make_map)
	Signals.remove_item.connect(_remove_item)
	Signals.set_items.connect(_set_items)


func get_only_floor() -> Dictionary:
	var result:Dictionary = {}
	for key in map.keys():
		if map[key] == FLOOR: result[key] = FLOOR
	return result


func get_walkable() -> Dictionary:
	var result:Dictionary = {}
	for key in map.keys():
		if map[key] in [FLOOR, DOOR, ENTRANCE, EXIT, HALLWAY, ENEMY, ITEM]: result[key] = FLOOR
	return result


func _make_map(dimensions: Vector2i) -> void:
	_clear_map(dimensions)

	var sliced := _slice_map(dimensions)
	var _coords := _sliced_coords(sliced)
	var sections := _get_sections()
	var _merged := _merge_slices(sliced, sections)
	_display_rooms()
	_check_connections(sections)
	_make_doors()
	_make_hallways()
	_set_entrance_and_exit()

	Signals.map_ready.emit()


func _clear_map(_dimension:Vector2i) -> void:
	map.clear()
	_rooms.clear()
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


func _sliced_coords(sliced:Array[Array]) -> Array[Array]:
	var sliced_coords:Array[Array] = []
	for row in sliced:
		var new_row:Array = []
		for value in row:
			new_row.append([Vector2i(value[0].x/8, value[0].y/8), Vector2i(value[1].x/8, value[1].y/8)])
		sliced_coords.append(new_row)
	return sliced_coords


func _get_sections() -> Array[Array]:
	var _room_count := randi_range(ROOMRANGES.x, ROOMRANGES.y)
	var sections:Array[Array] = [
		[null, null, null],
		[null, null, null],
		[null, null, null]
	]

	var current_room := 0
	var pos:Vector2i = Vector2i(randi_range(0,2), 0)
	while current_room < _room_count:
		while sections[pos.x][pos.y] != null:
			pos = Vector2i(randi_range(0,2), randi_range(0,2))

		sections[pos.x][pos.y] = current_room
		if _get_room_by_id(current_room) == null:
			var new_room:RoomData = RoomData.new()
			new_room.id = current_room
			_rooms.append(new_room)

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

			else:
				if _map[coords.x][coords.y][0].x < first.x: first.x  = _map[coords.x][coords.y][0].x
				if _map[coords.x][coords.y][0].y < first.y: first.y  = _map[coords.x][coords.y][0].y

				if _map[coords.x][coords.y][1].x > last.x: last.x  = _map[coords.x][coords.y][1].x
				if _map[coords.x][coords.y][1].y > last.y: last.y  = _map[coords.x][coords.y][1].y
			i += 1
		var room:RoomData = _get_room_by_id(key)
		var first_x:int = (first.x/8) + randi_range(XOFFSET[0], XOFFSET[1])
		var first_y:int = (first.y/8) + randi_range(YOFFSET[0], YOFFSET[1])
		var last_x:int = (last.x/8) - randi_range(XOFFSET[0], XOFFSET[1])
		var last_y:int = (last.y/8) - randi_range(YOFFSET[0], YOFFSET[1])
		room.room = [Vector2i(first_x, first_y), Vector2i(last_x, last_y)]

		new_map.append([first, last])

	return new_map


func _display_rooms() -> void:
	var all_cells:Array[Vector2i] = []

	# Walls
	for room in _rooms:
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
		y = room.first_cell.y
		while y <= room.last_cell.y:
			var cell := Vector2i(room.last_cell.x, y)
			all_cells.append(cell)
			map[cell] = WALL
			y += 1

	for room in _rooms:
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


func _make_doors() -> void:
	for room in _rooms:
		#print("ROOM ID: ",room.id)
		for wall in room.connecting_rooms.keys():
			var door_pos := Vector2i.ZERO
			var x_split:int = ((room.last_cell.x) - (room.first_cell.x))/room.connecting_rooms[wall].size()
			var y_split:int = ((room.last_cell.y) - (room.first_cell.y))/room.connecting_rooms[wall].size()
			var x:int = 0
			var y: int = 0
			var i := 0
			#print("WALL: ", wall)
			#print("Connection: ", room.connecting_rooms[wall])
			for each in room.connecting_rooms[wall]:
				x = randi_range(room.first_cell.x + (x_split * i), room.first_cell.x + (x_split * (i+1)))
				if x == room.first_cell.x: x += 1
				if x == room.last_cell.x: x -= 1
				y = randi_range(room.first_cell.y + (y_split * i), room.first_cell.y + (y_split * (i+1)))
				if y == room.first_cell.y: y += 1
				if y == room.last_cell.y: y -= 1
				match wall:
					&"up":
						door_pos = Vector2i(x, room.first_cell.y)
					&"down":
						door_pos = Vector2i(x , room.last_cell.y)
					&"left":
						door_pos = Vector2i(room.first_cell.x, y)
					&"right":
						door_pos = Vector2i(room.last_cell.x, y)
					_:
						pass
				i += 1

				tile_map_layer.set_cell(door_pos, 0, HORDOOR)
				map[door_pos] = DOOR
				room.add_door(wall, door_pos, each)


func _check_connections(sections:Array[Array]) -> void:
	#print(sections)
	for column in sections.size():
		for row in sections[column].size():
			if sections[column][row] != null:
				if column == 0:
					if sections[column+1][row] != null:
						if sections[column+1][row] != sections[column][row]:
							_get_room_by_id(sections[column][row]).add_connection(&"down", sections[column+1][row], Vector2i(column, row), Vector2i(column+1, row))
							_get_room_by_id(sections[column+1][row]).add_connection(&"up", sections[column][row], Vector2i(column+1, row), Vector2i(column, row))
					elif sections[column+1][row] == null:
						if sections[column+2][row] != null:
							if sections[column+2][row] != sections[column][row]:
								_get_room_by_id(sections[column][row]).add_connection(&"down", sections[column+2][row], Vector2i(column, row), Vector2i(column+2, row))
								_get_room_by_id(sections[column+2][row]).add_connection(&"up", sections[column][row], Vector2i(column+2, row), Vector2i(column, row))
						elif row < 2 and sections[column+2][row] == null and sections[column+2][row+1] != null:
							_get_room_by_id(sections[column][row]).add_connection(&"down", sections[column+2][row+1], Vector2i(column, row), Vector2i(column+2, row+1))
							_get_room_by_id(sections[column+2][row+1]).add_connection(&"up", sections[column][row], Vector2i(column+2, row+1), Vector2i(column, row))
				if column == 1:
					if sections[column+1][row] != null and sections[column+1][row] != sections[column][row]:
						_get_room_by_id(sections[column][row]).add_connection(&"down", sections[column+1][row], Vector2i(column, row), Vector2i(column+1, row))
						_get_room_by_id(sections[column+1][row]).add_connection(&"up", sections[column][row], Vector2i(column+1, row), Vector2i(column, row))

				if row == 0:
					if sections[column][row+1] != null:
						if sections[column][row+1] != sections[column][row]:
							_get_room_by_id(sections[column][row]).add_connection(&"right", sections[column][row+1], Vector2i(column, row), Vector2i(column, row+1))
							_get_room_by_id(sections[column][row+1]).add_connection(&"left", sections[column][row], Vector2i(column, row+1), Vector2i(column, row))
					if sections[column][row+1] == null and sections[column][row+2] != null and sections[column][row+2] != sections[column][row]:
						_get_room_by_id(sections[column][row]).add_connection(&"right", sections[column][row+2], Vector2i(column, row), Vector2i(column, row+2))
						_get_room_by_id(sections[column][row+2]).add_connection(&"left", sections[column][row], Vector2i(column, row+2), Vector2i(column, row))
				if row == 1:
					if sections[column][row+1] != null and sections[column][row+1] != sections[column][row]:
						_get_room_by_id(sections[column][row]).add_connection(&"right", sections[column][row+1], Vector2i(column, row), Vector2i(column, row+1))
						_get_room_by_id(sections[column][row+1]).add_connection(&"left", sections[column][row], Vector2i(column, row+1), Vector2i(column, row))


func _get_room_by_id(id:int) -> RoomData:
	for each in _rooms:
		if each.id == id: return each
	return null


func _identify_rooms() -> void:
	for room in _rooms:
		tile_map_layer.set_cell(room.center, 0, IDATLAS[room.id])


func _make_hallways() -> void:
	var all_cells:Array[Vector2i] = []
	for room in _rooms:
		for wall in room.doors.keys():
			for each in room.doors[wall]:
				var pos1:Vector2i = each[0]
				var con_room:RoomData = _get_room_by_id(each[1])
				var door2 = con_room.get_door_by_connection(room.id)
				var pos2:Vector2i = door2[0] if not door2.is_empty() else Vector2i.ZERO
				if pos2 != Vector2i.ZERO: room.add_hallway(pos1, pos2)

				var corner1:Vector2i
				var corner2:Vector2i

				match wall:
					&"down":
						var y:int = randi_range(pos1.y+1, pos2.y-1)
						corner1 = Vector2i(pos1.x, y)
						corner2 = Vector2i(pos2.x, y)
						var check_count := 0
						while not _is_path_valid(pos1, corner1, corner2, pos2, &"down") and check_count < 10:
							y = randi_range(pos1.y+1, pos2.y-1)
							corner1 = Vector2i(pos1.x, y)
							corner2 = Vector2i(pos2.x, y)
							check_count += 1

						if check_count >= 10: push_error("No valid path found for down path.")

						var current := pos1
						for i in corner1.y - pos1.y:
							current.y += 1
							all_cells.append(current)

						var distance:int = pos2.x - corner1.x if pos2.x >= corner1.x else corner1.x - pos2.x
						for i in distance:
							current.x = current.x + 1 if pos2.x >= corner1.x else current.x -1
							all_cells.append(current)

						for i in pos2.y - corner2.y - 1:
							current.y += 1
							all_cells.append(current)

					&"right":
						var x:int = randi_range(pos1.x+1, pos2.x-1)
						corner1 = Vector2i(x, pos1.y)
						corner2 = Vector2i(x, pos2.y)
						var check_count := 0
						while not _is_path_valid(pos1, corner1, corner2, pos2, &"right") and check_count < 10:
							x = randi_range(pos1.x+1, pos2.x-1)
							corner1 = Vector2i(x, pos1.y)
							corner2 = Vector2i(x, pos2.y)
							check_count += 1

						if check_count >= 10: push_error("No valid path found for down path.")

						var current := pos1
						for i in corner1.x - pos1.x:
							current.x += 1
							all_cells.append(current)

						var distance:int = pos2.y - corner1.y if pos2.y >= corner1.y else corner1.y - pos2.y
						for i in distance:
							current.y = current.y + 1 if pos2.y >= corner1.y else current.y - 1
							all_cells.append(current)

						for i in pos2.x - corner2.x - 1:
							current.x += 1
							all_cells.append(current)
					_:
						pass

	for each in all_cells:
		map[each] = HALLWAY
		tile_map_layer.set_cell(each, 0, Vector2i(1, 1))


func _is_path_valid(pos1:Vector2i, corner1:Vector2i, corner2:Vector2i, pos2:Vector2i, direction:StringName) -> bool:
	match direction:
		&"down":
			var current := pos1
			for i in corner1.y - pos1.y:
				if not map.has(current): return false
				if map.has(current) and map[current] in [FLOOR, WALL]: return false
				current.y += 1

			var distance:int = pos2.x - corner1.x if pos2.x >= corner1.x else corner1.x - pos2.x
			for i in distance:
				if not map.has(current): return false
				if map.has(current) and map[current] in [FLOOR, WALL]: return false
				current.x = current.x + 1 if pos2.x >= corner1.x else current.x -1

			for i in pos2.y - corner2.y - 1:
				if not map.has(current): return false
				if map.has(current) and map[current] in [FLOOR, WALL]: return false
				current.y += 1

		&"right":
			var current := pos1
			for i in corner1.x - pos1.x:
				if not map.has(current): return false
				if map.has(current) and map[current] in [FLOOR, WALL]: return false
				current.x += 1

			var distance:int = pos2.y - corner1.y if pos2.y >= corner1.y else corner1.y - pos2.y
			for i in distance:
				if not map.has(current): return false
				if map.has(current) and map[current] in [FLOOR, WALL]: return false
				current.y = current.y + 1 if pos2.y >= corner1.y else current.y - 1

			for i in pos2.x - corner2.x - 1:
				if not map.has(current): return false
				if map.has(current) and map[current] in [FLOOR, WALL]: return false
				current.x += 1
		_:
			pass

	return true


func _get_map_for_type(type:int) -> Dictionary:
	var result:Dictionary = {}
	for key in map.keys():
		if map[key] == type: result[key] = type
	return result


func _set_items(items:Array[ItemData]) -> void:
	var _floor := get_only_floor()
	assert(not _floor.is_empty(), "Floor plan is empty, why?")
	var keys := _floor.keys()
	#print(keys[0])
	#print("-------")
	for each in items:
		var choice := -1
		while choice == -1:
			choice = randi_range(0, _floor.size()-1)
			if _floor[keys[choice]] != FLOOR: choice = -1
		
		_floor[keys[choice]] = ITEM
		map[keys[choice]] = ITEM
		
		each.coords = keys[choice]
		item_layer.set_cell(each.coords, 0, each.atlas_coords)


func _remove_item(item_data:ItemData) -> void:
	map[item_data.coords] = FLOOR
	item_layer.erase_cell(item_data.coords)
