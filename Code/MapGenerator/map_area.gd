class_name MapArea


var w: get = _get_width
var h: get = _get_heigth
var _width: int
var _height: int


func _init(target_width: int, target_height: int) -> void:
	_width = target_width
	_height = target_height


func _get_width() -> int:
	return _width


func _get_heigth() -> int:
	return _height
