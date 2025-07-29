class_name RoomData extends Resource


var id:int = -1
var first_cell:Vector2i
var last_cell:Vector2i
var center:Vector2i:
	get:
		return (first_cell + last_cell)/2
var width:int
var height:int
var room:Array[Vector2i]:
	set(value):
		room = value
		if room.size() > 1:
			room.sort()
			first_cell = room[0]
			last_cell = room[-1]
			width = last_cell.x - first_cell.x
			height = last_cell.y - first_cell.y
var connecting_rooms:Dictionary = {}
var doors:Dictionary = {}
var hallways:Array[Array] = []


func add_connection(wall:StringName, room_id:int, origin_section:Vector2i, target_section:Vector2i) -> void:
	if connecting_rooms.has(wall):
		if not connecting_rooms[wall].has(room_id):
			connecting_rooms[wall][room_id] = target_section

	else: connecting_rooms[wall] = { room_id: target_section }

func add_door(wall:StringName, pos:Vector2i, connecting_room:int) -> void:
	if doors.has(wall): doors[wall].append([pos, connecting_room])
	else: doors[wall] = [[pos, connecting_room]]


func get_door_by_connection(room_id:int) -> Array:
	for key in doors.keys():
		for each in doors[key]:
			if each[1] == room_id: return each
	return []


func has_hallway(pos1:Vector2i, pos2:Vector2i) -> bool:
	for each in hallways:
		if each.has(pos1) and each.has(pos2): return true
	return false


func add_hallway(pos1:Vector2i, pos2:Vector2i) -> void:
	if has_hallway(pos1, pos2): return
	hallways.append([pos1, pos2])


func _is_path_blocked(origin:Vector2i, target:Vector2i) -> bool:
	for wall in connecting_rooms.keys():
		for room_id in connecting_rooms[wall].keys():
			if origin.x != target.x and origin.y == target.y:
				if target.x - origin.x > 1 or origin.x - target.x > 1:
					if connecting_rooms[wall][room_id].x == 1: return true
			if origin.y != target.y and origin.x == target.x:
				if target.y - origin.y > 1 or origin.y - target.y > 1:
					if connecting_rooms[wall][room_id].y == 1: return true
	return false
