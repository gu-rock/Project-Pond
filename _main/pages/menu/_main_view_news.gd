class_name MenuNews extends MainMenu.View

@onready var offline: PanelContainer = $list/offline
@onready var b_retry: UI_Butt_Text = $list/offline/box/b_retry

@onready var list: VBoxContainer = $list
@export var cards:Array[NewsCard] = []
var news:Array[Server.NewsFile] = []

func _ready() -> void:
	X.on_language.connect(_on_lang)
	offline.visible = false
	b_retry.tap.connect(_p_retry)
	b_retry.msg = "KEY_RETRY"
	for _u:Control in cards:
		_u.visible = false
		_u.modulate.a = 0.0

func _exit_tree() -> void:
	if X.on_language.is_connected(_on_lang):
		X.on_language.disconnect(_on_lang)

func _on_lang()->void:
	for _c:NewsCard in cards:
		if _c.file != null: _c.set_texts()

func _p_retry()->void:
	await _offline(false)
	var _online:bool = await C.connection_check()
	setup(_online)
	if !_online:
		X.noti_msg_show("KEY_NO_INTERNET",THEME.NOTI_CID.RED)

func setup(_online:bool)->void:
	if !_online:
		await _offline(true)
		return
	if news.is_empty():
		news.clear()
		var _ns:Array[Server.NewsFile] = await C.news_get()
		if _ns.is_empty(): return
		news = _ns
		var _id:int = 0
		for _n:Server.NewsFile in news:
			cards[_id].setup(_n)
			_card_show(cards[_id])
			_id += 1

func _offline(_in:bool)->void:
	var _t:Tween = create_tween()
	if _in:
		_t.tween_callback(
			func(): offline.visible = true
		)
		_t.tween_property(offline, "modulate:a", 1.0, 0.24)
	else:
		_t.tween_property(offline, "modulate:a", 0.0, 0.24)
		_t.tween_callback(
			func(): offline.visible = false
		)
	await _t.finished

func _card_show(_c:NewsCard)->void:
	_c.visible = true
	var _t:Tween = create_tween()
	_t.chain().tween_property(_c, "modulate:a", 1.0, 0.24)

func on_open()->void:
	pass

func on_close()->void:
	pass
