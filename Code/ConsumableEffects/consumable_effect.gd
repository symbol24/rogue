class_name ConsumableEffect extends Node


const POSTCONSUMEDELAY := 0.1


func consume(_item_data:ItemData) -> void:
	print("Consumed!")
	await get_tree().create_timer(POSTCONSUMEDELAY).timeout
	queue_free()
