class_name MainScreen extends SCREEN


@onready var version: Label = $canvas/version

@onready var border: Control = $canvas/border

@onready var bg: MainScreen_BG = $BG

func _exit_tree() -> void:
	bg.audio_dance.end()

#region MAIN
func _setup()->void:
	version.text = "V. " + XX.TIME.stamp_to_version(X.VERSION)
	version.self_modulate.a = 0.0
	await get_tree().create_timer(0.12).timeout

func roll_in()->void:
	await get_tree().create_timer(0.12).timeout

func roll_out()->void:
	if _cur_page != null: await _cur_page.pop_out()

func start()->void:
	bg.dance()
	var _prop:Array[JukeTrack] = []
	X.juke_playlist_set(_prop)
	await get_tree().create_timer(0.3).timeout
	await spark()
	await get_tree().create_timer(0.3).timeout
	var _tv:Tween = create_tween()
	_tv.tween_property(version, "self_modulate:a", 0.6, 0.9)

func resume()->void:
	pausing = false
	if _cur_page != null:
		await _cur_page.pop_in()
	await get_tree().create_timer(0.12).timeout

func pause()->void:
	pausing = true
	if _cur_page != null:
		await _cur_page.pop_out()
	await get_tree().create_timer(0.12).timeout
#endregion


## Local
var _cur_page:Page = null

var version_note:Server.VersionNoteFile = null

func spark()->void:
	var _page:Pages = Pages.MENU
	await bg.loading_start()
	var _online:bool = await C.connection_check()
	if _online:
		var _core:Server.CoreFile = await C.status_get()
		if _core != null:
			if X.version_outdated:
				_page = Pages.UPDATE
	await bg.loading_end()
	await page_switch(_page)

var _page_switching:bool = false
func page_switch(_to:Pages)->void:
	if _page_switching: return
	_page_switching = true
	var _prev:Page = null
	if _cur_page != null:
		_prev = _cur_page
		_prev.pop_out()
		_cur_page = null
	_cur_page = PagePaths[_to].instantiate()
	border.add_child(_cur_page)
	await bg.loading_start()
	await _cur_page.setup(self)
	await bg.loading_end()
	if !pausing: await _cur_page.pop_in()
	else: _cur_page.scale = SCREEN.POP_IN_SZ
	if _prev != null: _prev.queue_free()
	_page_switching = false



## Extend
enum Pages {UPDATE=0,MENU=1}
const PagePaths:Dictionary[Pages,PackedScene] = {
	Pages.UPDATE: preload("uid://yvq6cqeutyrq"),
	Pages.MENU: preload("uid://mqh1kn8v7232")
}

@abstract
class Page extends Control:
	var main:MainScreen = null
	
	func _ready() -> void:
		self.visible = false
		self.modulate.a = 0.0
	
	func setup(_m:MainScreen)->void:
		main = _m
		SCREEN.POP_SETUP(self)
		self.scale = SCREEN.POP_OUT_SZ
		await _onset()
	
	## Copy vv
	func _onset()->void:
		await get_tree().create_timer(0.12).timeout
	## Copy
	
	var _tw:Tween = null
	func pop_in()->void:
		SCREEN.POP_SETUP(self)
		self.visible = true
		if _tw: _tw.kill()
		_tw = create_tween().set_parallel()
		_tw.tween_property(self, "scale", POP_SZ, 0.24)
		_tw.tween_property(self, "modulate:a", 1.0, 0.18)
		_tw.chain().tween_interval(0.12)
		await _tw.finished
	
	func pop_out()->void:
		SCREEN.POP_SETUP(self)
		if _tw: _tw.kill()
		_tw = create_tween().set_parallel()
		_tw.tween_property(self, "scale", POP_IN_SZ, 0.24)
		_tw.tween_property(self, "modulate:a", 0.0, 0.18)
		_tw.chain().tween_interval(0.12)
		await _tw.finished
		self.visible = false
