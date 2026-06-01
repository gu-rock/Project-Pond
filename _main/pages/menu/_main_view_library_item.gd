class_name LibraryItem extends PanelContainer

static func LOAD()->PackedScene: return load("uid://d18y318yye2y")

@onready var opts: HBoxContainer = $panel/opts # size m

@onready var cover: UI_ImageCloud = $panel/cover
@onready var title: Label = $panel/title

@onready var date_release: Label = $panel/info/box/date_release
@onready var version: Label = $panel/info/box2/version
@onready var tags: Label = $panel/info/box3/tags
@onready var downloads: Label = $panel/info/box4/downloads

@onready var b_play: UI_Butt_Text = $panel/opts/b_play
@onready var b_open: UI_Butt_Text = $panel/opts/b_open
@onready var b_download: UI_Butt_Text = $panel/opts/b_download

var _main:MainMenu = null
var file:Server.GameFile = null

func _ready() -> void:
	b_play.msg = "KEY_PLAY"
	b_play.tap.connect(_p_play)
	b_open.msg = "KEY_VIEW"
	b_open.tap.connect(_p_open)
	b_download.msg = "KEY_DOWNLOAD"
	b_download.tap.connect(_p_download)
	b_download.visible = false

func setup(_f:Server.GameFile, _m:MainMenu)->void:
	_main = _m
	file = _f
	cover.load_images([file.cover])
	title.text = file.title
	date_release.text = XX.TIME.date_yyyy_mm_dd(file.release)
	version.text = XX.TIME.stamp_to_version(file.version)
	tags.text = ""
	var _tid:int = 0
	for _tg in file.tags:
		tags.text += str(_tg)
		if _tid < file.tags.size()-1: tags.text += ", "
		_tid += 1
	downloads.text = str(file.downloads)
	sync_local_games()

func sync_local_games()->void:
	b_open.visible = !file.screenshots.is_empty()
	var _have:bool = X.games.keys().has(file.id) and !X.deleted.has(file.id)
	var _has_link:bool = !file.link.is_empty()
	b_play.visible = _have
	if _have:
		var _loc:GameInfo = X.games[file.id]
		if _has_link:
			if file.version > _loc.version:
				b_download.msg = "KEY_UPDATE"
				b_download.visible = true
			else:
				b_download.visible = false
				b_download.msg = "KEY_DOWNLOAD"
		else:
			b_download.visible = false
	else:
		b_download.msg = "KEY_DOWNLOAD"
		b_download.visible = _has_link

func _p_play()->void:
	b_play.tap.disconnect(_p_play)
	b_open.tap.disconnect(_p_open)
	b_download.tap.disconnect(_p_download)
	X.screen_load(X.games[file.id].screen)

func _p_open()->void:
	_main.game_view_show(file)

func _p_download()->void:
	C.game_download(file)
