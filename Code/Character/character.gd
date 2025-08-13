class_name Character extends Node2D


var _current_location:Vector2i = Vector2i.ZERO:
	set(value):
		_current_location = value
		GM.run_selected_character.current_pos = _current_location
var _input:InputProcess
var _ready_sent := false



func _ready() -> void:
	Signals.input_focuse_changed.connect(_input_focus_changed)
	Signals.consume_item.connect(_consume_item)
	Signals.equip_gear.connect(_equip_gear)
	Signals.gain_experience.connect(_gain_experience)


func setup_character(coords:Vector2i) -> void:
	_current_location = coords
	_setup_input()


func move_character(direction:StringName) -> void:
	var new_pos:Vector2i = _current_location
	match direction:
		&"up":
			new_pos += Vector2i.UP
		&"down":
			new_pos += Vector2i.DOWN
		&"left":
			new_pos += Vector2i.LEFT
		&"right":
			new_pos += Vector2i.RIGHT
		_:
			pass

	if GM.map_generator != null and GM.map_generator.map.has(new_pos) and GM.map_generator.map[new_pos] != MapGenerator.WALL:
		if GM.map_generator.map[new_pos] in [MapGenerator.FLOOR, MapGenerator.DOOR, MapGenerator.ENTRANCE, MapGenerator.EXIT, MapGenerator.HALLWAY, MapGenerator.ITEM]:
			_current_location = new_pos
			global_position = _current_location * MapGenerator.TILESIZE

			if GM.map_generator.map[_current_location] == MapGenerator.ITEM:
				_pickup_item(_current_location)
	
		elif GM.map_generator.map[new_pos] == MapGenerator.ENEMY:
			var enemy:Enemy = GM.spawn_manager.get_enemy_by_coords(new_pos)
			var chance := randf()
			var message := "You missed %s with your wild attack."
			if chance <= GM.run_selected_character.dex:
				var damage:int = -GM.run_selected_character.physical_power # damage is "-"
				message = "You hit the %s with a strong attack."
				if chance <= CharacterData.CRITCHANCE:
					damage *= CharacterData.CRITBONUS
					message = "You clobbered the %s with a monster of a swing."
				
				var effect := HpEffectData.new()
				effect.flat_hp_amount = damage
				Signals.add_effect_to_target.emit(enemy, effect)
			Signals.display_message.emit(message % enemy.data.display_name)

	Signals.action_tick.emit()
			

func interact() -> void:
	if GM.map_generator != null and GM.map_generator.map.has(_current_location):
		if GM.map_generator.map[_current_location] == MapGenerator.ENTRANCE:
			Signals.display_message.emit("This is the entrance, you cannot go back up!")
		elif GM.map_generator.map[_current_location] == MapGenerator.EXIT:
			GM.run_selected_character.go_to_next_biome_level()
			await get_tree().create_timer(0.1).timeout
			Signals.load_scene.emit(Biome.Identity.keys()[GM.run_selected_character.biome], true, true)


func unregister_input() -> void:
	_input.unregister()


func _setup_input() -> void:
	_input = CharacterInputProcess.new()
	add_child(_input)
	_input.name = &"character_input_0"
	if not _input.is_node_ready(): await _input.ready
	_input.register()


func _input_focus_changed() -> void:
	if _ready_sent: return
	Signals.character_ready.emit(self)
	_ready_sent = true


func _exit_tree() -> void:
	_input.unregister()


func _pickup_item(coords:Vector2i) -> void:
	var new_item:ItemData = GM.spawn_manager.get_item_by_coords(coords)
	if new_item != null:
		GM.run_selected_character.pickup(new_item)
		Signals.remove_item.emit(new_item)


func _consume_item(comsumable_data:ConsumableData) -> void:
	var result = comsumable_data.consume(self)
	if result <= 0:
		GM.run_selected_character.remove_item(comsumable_data)
	Signals.item_consumed.emit(comsumable_data)
	GM.run_selected_character.add_item_to_known(comsumable_data.id)


func _equip_gear(gear_data:GearData) -> void:
	GM.run_selected_character.equip(gear_data)
	Signals.gear_updated.emit()


func _gain_experience(value:int = 0) -> void:
	GM.run_selected_character.add_xp(value)
