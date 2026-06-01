class_name MenuLibrary extends MainMenu.View

@onready var grid: GridContainer = $grid

var _main:MainMenu = null
var _card_sz:float = 330.0

@onready var offline: PanelContainer = $grid/offline
@onready var b_retry: UI_Butt_Text = $grid/offline/box/b_retry

var items:Array[Server.GameFile] = []
var cards:Array[LibraryItem] = []

func _exit_tree() -> void:
	if X.on_games_update.is_connected(_on_games_updated):
		X.on_games_update.disconnect(_on_games_updated)

func _ready() -> void:
	_main = get_parent()
	self.draw.connect(_sizing)
	X.on_games_update.connect(_on_games_updated)
	modulate.a = 0.0
	offline.modulate.a = 0.0
	offline.visible = false
	b_retry.tap.connect(_p_retry)
	b_retry.msg = "KEY_RETRY"

func _on_games_updated()->void:
	if cards.is_empty():
		if items.is_empty():
			items = await C.games_get_all()
			for _i:Server.GameFile in items:
				var _c:LibraryItem = LibraryItem.LOAD().instantiate()
				grid.add_child(_c)
				cards.append(_c)
				_c.setup(_i,_main)
				_c.visible = true
				_c.modulate.a = 1.0
	else:
		for _c:LibraryItem in cards:
			_c.sync_local_games()
	
	_sizing()

func _sizing()->void:
	var _cur_rat:float = self.size.x/_card_sz
	if int(_cur_rat) != grid.columns: _sizing_anim(int(_cur_rat))
	#if int(_cur_rat) != grid.columns and grid.columns > 1:
		#_sizing_anim(int(_cur_rat))

var _t:Tween = null
func _sizing_anim(_s:int)->void:
	if _t: _t.kill()
	_t = create_tween()
	_t.tween_property(grid, "modulate:a" , 0.0, 0.12)
	_t.tween_callback(
		func(): grid.columns = _s
	)
	_t.tween_interval(0.06)
	_t.tween_property(grid, "modulate:a" , 1.0, 0.24)


func setup(_online:bool)->void:
	if !_online:
		await _offline(true)
		return
	_on_games_updated()

func on_open()->void:
	_sizing()

func on_close()->void:
	pass


func _p_retry()->void:
	await _offline(false)
	var _online:bool = await C.connection_check()
	setup(_online)
	if !_online:
		X.noti_msg_show("KEY_NO_INTERNET",THEME.NOTI_CID.RED)

func _offline(_in:bool)->void:
	var _tsw:Tween = create_tween()
	if _in:
		_tsw.tween_callback(
			func(): offline.visible = true
		)
		_tsw.tween_property(offline, "modulate:a", 1.0, 0.24)
	else:
		_tsw.tween_property(offline, "modulate:a", 0.0, 0.24)
		_tsw.tween_callback(
			func(): offline.visible = false
		)
	await _tsw.finished
