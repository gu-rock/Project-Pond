class_name MainMenu extends MainScreen.Page

@onready var b_me: UI_Butt_Text = $topbar/l_bar/b_me

@onready var b_news: UI_Butt_Text = $topbar/r_bar/b_news
@onready var b_games: UI_Butt_Text = $topbar/r_bar/b_games
@onready var b_library: UI_Butt_Text = $topbar/r_bar/b_library
@onready var b_account: UI_Butt_Text = $topbar/r_bar/b_account
@onready var b_options: UI_Butt_Text = $topbar/r_bar/b_settings
@onready var b_exit: UI_Butt_Text = $topbar/r_bar/b_exit

@onready var view_news: MenuNews = $news
@onready var view_games: MainMenu_Games = $games
@onready var view_library: MenuLibrary = $library
@onready var view_account: MenuAccount = $account
@onready var view_settings: Menu_Settings = $settings

@onready var detail_view: Menu_Detail = $detail
@onready var download_view: Menu_Download = $download
@onready var options_view: Menu_Options = $options


var _butts:Array[UI_Butt_Text] = []
var _views:Array[View] = []


func _exit_tree() -> void:
	if C.on_game_download.is_connected(on_game_download):
		C.on_game_download.disconnect(on_game_download)

func _onset()->void:
	_butts.append_array([b_news,b_games,b_library,b_account,b_options])
	_views.append_array([view_news,view_games,view_library,view_account,view_settings])
	var _online:bool = await C.connection_check()
	for _b:UI_Butt_Text in _butts: _b.selected = false
	for _v:View in _views:
		_v.visible = false
		_v.modulate.a = 0.0
	_set_butts()
	for _v:View in _views: await _v.setup(_online)
	if _online: _p_news()
	else: _p_games()
	C.on_game_download.connect(on_game_download)
	offline_mode(!_online)

func offline_mode(_offline:bool)->void:
	pass
	#for _b:UI_Butt_Text in [b_news,b_library]:
		#_b.visible = !_offline

## Butts
var _cur_idx:int = -1
func _set_butts()->void:
	b_me.msg = "About me"
	b_me.tap.connect(_p_me)
	b_news.msg = "KEY_NEWS"
	b_games.msg = "KEY_GAMES"
	b_library.msg = "KEY_LIBRARY"
	b_account.msg = "KEY_ACCOUNT"
	b_options.msg = "KEY_SETTINGS"
	b_exit.msg = "KEY_QUIT"
	b_news.tap.connect(_p_news)
	b_games.tap.connect(_p_games)
	b_library.tap.connect(_p_library)
	b_account.tap.connect(_p_account)
	b_options.tap.connect(_p_options)
	b_exit.tap.connect(_p_exit)

func _p_me()->void:
	C.open_link(XX.LINK_GITHUB_PROFILE)

func _p_news()->void:
	if _cur_idx == 0: return
	var _prev:int = _cur_idx
	_cur_idx = 0
	_switch_menu(_prev)

func _p_games()->void:
	if _cur_idx == 1: return
	var _prev:int = _cur_idx
	_cur_idx = 1
	_switch_menu(_prev)

func _p_library()->void:
	if _cur_idx == 2: return
	var _prev:int = _cur_idx
	_cur_idx = 2
	_switch_menu(_prev)

func _p_account()->void:
	if _cur_idx == 3: return
	var _prev:int = _cur_idx
	_cur_idx = 3
	_switch_menu(_prev)

func _p_options()->void:
	if _cur_idx == 4: return
	var _prev:int = _cur_idx
	_cur_idx = 4
	_switch_menu(_prev)

func _p_exit()->void:
	X.overlay_quit()

var _t:Tween = null
func _switch_menu(_prev:int)->void:
	if _t: _t.kill()
	_t = create_tween().set_parallel()
	
	_butts[_cur_idx].selected = true
	if _prev >= 0:
		_butts[_prev].selected = false
		_t.tween_property(_views[_prev], "modulate:a", 0.0, 0.18)
		_t.chain().tween_callback(
			func():
				_views[_prev].visible = false
				_views[_prev].on_close()
		)
	_t.chain().tween_callback(
		func():
			_views[_cur_idx].visible = true
	)
	_t.chain().tween_property(_views[_cur_idx], "modulate:a", 1.0, 0.18)
	_t.chain().tween_callback(
		func():
			_views[_cur_idx].on_open()
	)

## Overlay
func game_view_show(_f:Server.GameFile)->void:
	await detail_view.view(_f)

func game_options_show(_info:GameInfo)->void:
	await options_view.open(_info)

func on_game_download(_loader:CLOUD.GameLoader)->void:
	download_view.download_start(_loader)


## Classes
class View extends ScrollContainer:
	func setup(_online:bool)->void:
		await get_tree().create_timer(0.12).timeout
	func on_open()->void: pass
	func on_close()->void: pass
