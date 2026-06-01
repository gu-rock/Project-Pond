class_name GAME extends SCREEN

@export var info:GameInfo = null

#region MAIN ############################################################
func _enter_tree() -> void:
	X.on_language.connect(on_lang)

func _exit_tree() -> void:
	if X.on_language.is_connected(on_lang): X.on_language.disconnect(on_lang)

func _setup()->void:
	file_load()
	_translate_check()
	_gamepad_check()
	if !Input.joy_connection_changed.is_connected(_gamepad_changed):
		Input.joy_connection_changed.connect(_gamepad_changed)
	await on_setup()
	on_lang()
	

func to_main()->void:
	file_update_time(false)
	await on_quit()
	_translate_remove()
	X.screen_load(SCREEN.MAINMENU_PATH)

func file_load()->void:
	var _user:CONFIG.User = CONFIG.User.new()
	info.file = _user.game_load(info.id, info.version)
	info.file.time_updated = XX.TIME.stamp_now()

func file_update_time(_noti:bool = true)->void:
	var _now:int = XX.TIME.stamp_now()
	var _played:int = _now - info.file.time_updated
	info.file.time_updated = _now
	info.file.time_played += _played
	if _noti:
		X.noti_msg_show("KEY_NOTI_DATA", THEME.NOTI_CID.YELLOW)
	var _user:CONFIG.User = CONFIG.User.new()
	_user.game_save(info.file)

func file_save(_d:Dictionary, _noti:bool = true)->void:
	var _now:int = XX.TIME.stamp_now()
	var _played:int = _now - info.file.time_updated
	info.file.time_updated = _now
	info.file.time_played += _played
	if !_d.is_empty():
		info.file.update(_d)
	if _noti:
		X.noti_msg_show("KEY_NOTI_DATA", THEME.NOTI_CID.YELLOW)
	var _user:CONFIG.User = CONFIG.User.new()
	_user.game_save(info.file)
#endregion

#region TRANSLATE
@export var _translates:Array[Translation] = []
func _translate_check()->void:
	for _t:Translation in _translates:
		if !TranslationServer.has_translation(_t):
			TranslationServer.add_translation(_t)

func _translate_remove()->void:
	for _t:Translation in _translates:
		if TranslationServer.has_translation(_t):
			TranslationServer.remove_translation(_t)
#endregion



#region GAMEPAD ####################################################
var is_gamepad:bool = false
signal on_gamepad(_connect:bool)
func _gamepad_check()->void:
	if Input.get_connected_joypads().is_empty(): return
	_gamepad_changed(0, true)

var _tpad:Tween = null
func _gamepad_changed(_device:int, _connect:bool)->void:
	if _tpad: _tpad.kill()
	_tpad = create_tween()
	_tpad.tween_interval(0.6)
	_tpad.tween_callback(
		func():
			if Input.get_connected_joypads().is_empty():
				is_gamepad = false
				on_gamepad.emit(false)
				X.noti_msg_yellow(tr("KEY_JOY_DISCONNECT"))
			else:
				is_gamepad = true
				on_gamepad.emit(true)
				X.noti_msg_green(tr("KEY_JOY_CONNECT") + Input.get_joy_name(_device))
	)
#endregion


## Classes
class File extends RefCounted:
	var _data:Dictionary = {}
	
	var id:String = ""
	var version:int = 0
	var time_created:int = 0
	var time_updated:int = 0
	var time_played:int = 0
	
	func _init()->void: _data = {}
	func update(_d:Dictionary)->void: _data = _d.duplicate()


#########################################################################
############################# GAME LOCAL ################################
#########################################################################

func on_setup()->void: await get_tree().create_timer(0.24).timeout
func on_quit()->void: await get_tree().create_timer(0.24).timeout
func on_lang()->void: pass
func roll_in()->void: await get_tree().create_timer(0.24).timeout
func roll_out()->void: await get_tree().create_timer(0.24).timeout

func start()->void: await get_tree().create_timer(0.24).timeout
func resume()->void: await get_tree().create_timer(0.24).timeout
func pause()->void: await get_tree().create_timer(0.24).timeout
