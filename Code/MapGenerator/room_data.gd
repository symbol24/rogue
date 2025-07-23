class_name RoomData extends Resource


var id:int = -1
var first_cell:Vector2i
var last_cell:Vector2i
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
