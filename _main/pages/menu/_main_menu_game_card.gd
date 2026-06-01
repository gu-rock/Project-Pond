class_name GameCard extends PanelContainer

@onready var cover: TextureRect = $panel/cover

@onready var title: Label = $panel/info/title
@onready var version: Label = $panel/info/box/version
@onready var play_time: Label = $panel/info/box2/b/play_time
@onready var last_play: Label = $panel/info/box3/last_play

@onready var b_opts: UI_Butt_Icon = $panel/opts/b_opts
@onready var b_play: UI_Butt_Icon = $panel/opts/b_play

var info:GameInfo = null
var _main:MainMenu = null

func set_info(_c:GameInfo, _m:MainMenu)->void:
	_main = _m
	info = _c
	if info.cover != null: cover.texture = info.cover
	title.text = info.title
	version.text = XX.TIME.stamp_to_version(info.version)
	if info.file.time_updated > 1:
		last_play.text = XX.TIME.datetime(info.file.time_updated)
		play_time.text = XX.TIME.played_time(info.file.time_played)
	else:
		last_play.text = "--/--/--"
		play_time.text = "--:--"
	
	b_opts.tap.connect(_p_options)
	b_play.tap.connect(_p_play)

func _p_delete()->void:
	_main.game_delete(info)

func _p_options()->void:
	_main.game_options_show(info)

func _p_play()->void:
	b_opts.tap.disconnect(_p_options)
	b_play.tap.disconnect(_p_play)
	X.screen_load(info.screen)
