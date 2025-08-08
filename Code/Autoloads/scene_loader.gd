class_name SceneManager extends Node


const EXTRA_TIME := 2.0


@export var scenes_lo_load:Dictionary = {}

var current_level:Node2D = null
var _to_load := &""
var _loading := false
var _load_complete := false
var _loading_status:ResourceLoader.ThreadLoadStatus
var _progress := []
var _extra_time := false


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.load_scene.connect(_load_scene)


func _process(_delta: float) -> void:
	if _loading:
		_loading_status = ResourceLoader.load_threaded_get_status(scenes_lo_load[_to_load], _progress)
		#print("loading ", _to_load , ": ", _progress[0]*100, "%")
		if _loading_status == ResourceLoader.THREAD_LOAD_LOADED:
			if not _load_complete:
				_load_complete = true
				_complete_load()


func _load_scene(id:StringName, disply_loading:bool, extra_time:bool) -> void:
	if not scenes_lo_load.has(id):
		push_warning("'%s' is not in the list of scenes available to load!" % id)
		return

	_extra_time = extra_time
	Signals.toggle_loading_screen.emit(disply_loading)
	_to_load = id
	_load_complete = false
	_loading_status = ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE
	get_tree().paused = true

	if current_level != null:
		var temp = current_level
		current_level = null
		remove_child(temp)
		temp.queue_free.call_deferred()

	ResourceLoader.load_threaded_request(scenes_lo_load[_to_load])
	_loading = true
	_loading_status = ResourceLoader.load_threaded_get_status(scenes_lo_load[_to_load], _progress)


func _complete_load() -> void:
	_loading = false
	current_level = ResourceLoader.load_threaded_get(scenes_lo_load[_to_load]).instantiate()
	add_child(current_level)
	if not current_level.is_node_ready(): await current_level.ready
	if _extra_time: await get_tree().create_timer(EXTRA_TIME).timeout
	get_tree().paused = false
	if current_level is Biome: Signals.toggle_rid_control.emit(&"in_game_ui", true, &"")
	Signals.toggle_loading_screen.emit(false)
