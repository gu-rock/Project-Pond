class_name Menu_Detail extends Panel

signal done

@onready var content: ScrollContainer = $border/content

@onready var b_close: UI_Butt_Text = $border/topbar/r_bar/b_close

@onready var title: Label = $border/topbar/title
@onready var cover: UI_ImageCloud = $border/content/list/info/cover
@onready var version_v: Label = $border/content/list/info/detail/version/version_v
@onready var tags_v: Label = $border/content/list/info/detail/tags/tags_v
@onready var date_release_v: Label = $border/content/list/info/detail/date_release/date_release_v
@onready var downloads_v: Label = $border/content/list/info/detail/downloads/downloads_v
@onready var about: Label = $border/content/list/about
@onready var screenshots: UI_ImageSlider = $border/content/list/screenshots


func _set_content(_info:Server.GameFile)->void:
	title.text = _info.title
	cover.load_images([_info.cover])
	version_v.text = XX.TIME.stamp_to_version(_info.version)
	var _tid:int = 0
	for _tg in _info.tags:
		tags_v.text += str(_tg)
		if _tid < _info.tags.size()-1: tags_v.text += ", "
		_tid += 1
	date_release_v.text = XX.TIME.date_yyyy_mm_dd(_info.release)
	downloads_v.text = str(_info.downloads)
	about.text = _info.detail[X.settings.language]
	screenshots.images_get(_info.screenshots)

func _reset_content()->void:
	title.text = ""
	cover.reset()
	version_v.text = ""
	tags_v.text = ""
	date_release_v.text = ""
	downloads_v.text = ""
	about.text = ""
	screenshots.reset()
	content.scroll_vertical = 0

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	b_close.msg = "KEY_CLOSE"

func view(_info:Server.GameFile)->void:
	if _info == null:
		pass
	else:
		_set_content(_info)
	
	await _in()
	b_close.tap.connect(p_close)
	await done
	b_close.tap.disconnect(p_close)
	await _out()
	_reset_content()


func p_close()->void:
	done.emit()

## Screenshot Slider


## Anim
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
