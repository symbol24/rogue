class_name Item extends Node2D


var data:ItemData


func setup_item_data(new_data:ItemData) -> void:
	assert(new_data != null, "Item has not received any data to set.")
	data = new_data.duplicate()
