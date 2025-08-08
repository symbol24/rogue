class_name HealthPotionEffect extends ConsumableEffect


func consume(_item_data:ItemData) -> void:
	assert(_item_data is ConsumableData, "Health potion effect Consume did not receive consumable data.")
	assert(_item_data.extra_data.has(&"hp_percent"), "Health potion effect Consume did not receive 'hp_percent' in extra data'.")
	
	var value:int = int(_item_data.extra_data[&"hp_percent"] * GM.run_selected_character.max_hp)
	print("Consumed hp potion for %s hp." % int(_item_data.extra_data[&"hp_percent"] * GM.run_selected_character.max_hp))
	GM.run_selected_character.update_hp(value)
	await get_tree().create_timer(POSTCONSUMEDELAY).timeout
	queue_free()
