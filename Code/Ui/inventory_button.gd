class_name InventoryButton extends Button


var item_data:ItemData


func _ready() -> void:
	focus_entered.connect(_focus_entered)
	focus_exited.connect(_focus_exited)


func setup_inventory_button(new_data:ItemData) -> void:
	assert(new_data != null, "Inventory button received null item data.")
	item_data = new_data
	text = item_data.get_description(GM.run_selected_character.known_items)


func _focus_entered() -> void:
	text = item_data.get_description(GM.run_selected_character.known_items)
	match item_data.type:
		ItemData.Type.CONSUMABLE:
			text += " [Q to Use]"
		ItemData.Type.GEAR:
			text += " [E to Equip]"
		_:
			pass


func _focus_exited() -> void:
	text = item_data.get_description(GM.run_selected_character.known_items)
