class_name Menu_Options extends Panel

@onready var menu: PanelContainer = $menu
@onready var b_delete_game: UI_Butt_Text = $menu/list/b_delete_game
@onready var b_delete_save: UI_Butt_Text = $menu/list/b_delete_save
@onready var b_close: UI_Butt_Text = $menu/list/b_close

@onready var cf_panel: PanelContainer = $confirm
@onready var cf_header: Label = $confirm/list/header
@onready var cf_b_yes: UI_Butt_Text = $confirm/list/opts/b_yes
@onready var cf_b_no: UI_Butt_Text = $confirm/list/opts/b_no

var _game_info:GameInfo = null

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	
	## Menu
	menu.visible = false
	menu.modulate.a = 0.0
	b_delete_game.msg = "KEY_REMOVE_GAME"
	b_delete_save.msg = "KEY_REMOVE_SAVE"
	b_close.msg = "KEY_CLOSE"
	
	## Cf Menu
	cf_panel.visible = false
	cf_panel.modulate.a = 0.0
	cf_b_yes.msg = "KEY_CONFIRM"
	cf_b_no.msg = "KEY_CANCEL"
	cf_b_yes.tap.connect(
		func(): _pick.emit(true)
	)
	cf_b_no.tap.connect(
		func(): _pick.emit(false)
	)

func open(_info:GameInfo)->void:
	_game_info = _info
	await _in()
	_menu_start()
	b_delete_game.tap.connect(_cf_delete_game)
	b_delete_save.tap.connect(_cf_delete_save)
	b_close.tap.connect(close)

func close()->void:
	b_delete_game.tap.disconnect(_cf_delete_game)
	b_delete_save.tap.disconnect(_cf_delete_save)
	b_close.tap.disconnect(close)
	await _menu_end()
	await _out()
	_game_info = null

func _menu_start()->void:
	menu.visible = true
	var _t:Tween = create_tween()
	_t.tween_property(menu, "modulate:a", 1.0, 0.24)
	await _t.finished

func _menu_end()->void:
	var _t:Tween = create_tween()
	_t.tween_property(menu, "modulate:a", 0.0, 0.24)
	await _t.finished
	menu.visible = false

signal _pick(_ok:bool)
func _cf_delete_game()->void:
	_menu_end()
	cf_header.text = X.TR_ADD("KEY_REMOVE_GAME_CF", _game_info.title)
	cf_panel.visible = true
	var _t:Tween = create_tween()
	_t.tween_property(cf_panel, "modulate:a", 1.0, 0.24)
	await _t.finished
	var _ok:bool = await _pick
	await _cf_end()
	if _ok:
		X.game_delete(_game_info)
		await close()

func _cf_delete_save()->void:
	_menu_end()
	cf_header.text = X.TR_ADD("KEY_REMOVE_SAVE_CF", _game_info.title)
	cf_panel.visible = true
	var _t:Tween = create_tween()
	_t.tween_property(cf_panel, "modulate:a", 1.0, 0.24)
	await _t.finished
	var _ok:bool = await _pick
	await _cf_end()
	if _ok:
		X.gamedata_delete(_game_info)
		await close()

func _cf_end()->void:
	var _t:Tween = create_tween()
	_t.tween_property(cf_panel, "modulate:a", 0.0, 0.24)
	await _t.finished
	cf_panel.visible = false
	_menu_start()

## In Out
func _in()->void:
	var _t: Tween = create_tween()
	_t.tween_callback(
		func(): visible = true
	)
	_t.tween_property(self, "modulate:a", 1.0, 0.24)
	await _t.finished

func _out()->void:
	var _t: Tween = create_tween()
	_t.tween_property(self, "modulate:a", 0.0, 0.24)
	_t.tween_callback(
		func(): visible = false
	)
	await _t.finished
