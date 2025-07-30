class_name Ui extends CanvasLayer


const LOADINGSCREEN := "uid://id3iht3nckov"
const MAINMENU := "uid://dshqh8pnjd3uy"
const CHARACTERSELECT := "uid://dbuyvt65oinsr"


var _loading_screen:LoadingScreen = null
var rid_controls:Array[RidControl] = []
var previous_rid_control := &""


func _ready() -> void:
	Signals.toggle_loading_screen.connect(_toggle_loading_screen)
	Signals.toggle_rid_control.connect(_toggle_rid_controls)


func _toggle_rid_controls(_id:StringName, display:bool, previous:StringName = &"") -> void:
	previous_rid_control = previous
	var found := false
	for each in rid_controls:
		each.toggle_rid_control(false)
		if each.id == _id: 
			each.toggle_rid_control(display)
			found = true

	if not found:
		var new:RidControl = _get_ui(_id)
		new.toggle_rid_control(true)
		rid_controls.append(new)


func _toggle_loading_screen(display:bool) -> void:
	if _loading_screen == null: _loading_screen = _get_ui(&"loading_screen")
	if display:
		if _loading_screen.get_index() < get_child_count(): move_child(_loading_screen, get_child_count())
		_loading_screen.show()
	else:
		_loading_screen.hide()


func _get_ui(id:StringName) -> Control:
	var result:Control = null
	match id:
		&"main_menu":
			result = load(MAINMENU).instantiate()
		&"loading_screen":
			result = load(LOADINGSCREEN).instantiate()
		&"character_select":
			result = load(CHARACTERSELECT).instantiate()
		_:
			pass

	if result != null:
		add_child(result)

	return result
