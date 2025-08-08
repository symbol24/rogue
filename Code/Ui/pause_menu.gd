class_name PauseMenu extends RidControl


const INVENTORYBUTTON := preload("uid://d1sfqlpk6f4np")


@onready var inventory_vbox: VBoxContainer = %inventory_vbox
@onready var pause_message: Label = %pause_message
@onready var ridsb_back: Button = %ridsb_back

var active_item:ItemData = null
var inventory_buttons:Array[InventoryButton] = []
var active_pos := 0


func _ready() -> void:
	Signals.consume_button_pressed.connect(_consume_item)
	Signals.item_consumed.connect(_item_consumed)
	Signals.move_selection_up_down.connect(_move_selection)


func toggle_rid_control(display:bool) -> void:
	if display:
		pause_message.text = ""
		_display_inventory()
		active_pos = 0
		if not inventory_buttons.is_empty():
			inventory_buttons[active_pos].grab_focus()
		else:
			ridsb_back.grab_focus()
		show()
	else:
		hide()
		_clear_inventory()


func _display_inventory() -> void:
	if GM.run_selected_character.inventory.is_empty():
		_add_empty_inventory_label()
		return

	for each in GM.run_selected_character.inventory:
		var new_button := INVENTORYBUTTON.instantiate()
		inventory_vbox.add_child(new_button)
		if not new_button.is_node_ready(): await new_button.ready
		new_button.setup_inventory_button(each)
		inventory_buttons.append(new_button)


func _clear_inventory() -> void:
	inventory_buttons.clear()
	for child in inventory_vbox.get_children():
		child.queue_free()


func _consume_item() -> void:
	if inventory_buttons.is_empty(): return
	if inventory_buttons[active_pos].item_data.type == ItemData.Type.CONSUMABLE:
		Signals.consume_item.emit(inventory_buttons[active_pos].item_data)


func _item_consumed(_item_data:ConsumableData) -> void:
	pause_message.text = _item_data.consume_message
	_clear_inventory()
	_display_inventory()
	if inventory_vbox.get_child_count() > 0:
		await get_tree().create_timer(0.1).timeout
		inventory_vbox.get_children()[0].grab_focus()
	else:
		ridsb_back.grab_focus()


func _add_empty_inventory_label() -> void:
	var new_label := Label.new()
	inventory_vbox.add_child(new_label)
	if not new_label.is_node_ready(): await new_label.ready
	new_label.text = "Inventory empty"


func _move_selection(target:StringName, is_up := false) -> void:
	if target != &"pause_menu": return
	if is_up:
		active_pos -= 1
		if active_pos < 0: active_pos = inventory_buttons.size()
	else:
		active_pos += 1
		if active_pos > inventory_buttons.size(): active_pos = 0
	
	if active_pos == inventory_buttons.size(): ridsb_back.grab_focus()
	else: inventory_buttons[active_pos].grab_focus()

	pause_message.text = ""