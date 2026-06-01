class_name Menu_Download extends Panel

@onready var panel_download: PanelContainer = $panel_download
@onready var header: Label = $panel_download/list/header
@onready var detail: Label = $panel_download/list/detail
@onready var progress: ProgressBar = $panel_download/list/box/progress
@onready var b_cancel: UI_Butt_Text = $panel_download/list/box/b_cancel

@onready var panel_result: PanelContainer = $panel_result
@onready var header_result: Label = $panel_result/list/header
@onready var b_close: UI_Butt_Text = $panel_result/list/b_close

var _loader:CLOUD.GameLoader = null

func _ready() -> void:
	self.visible = false
	self.modulate.a = 0.0
	_reset()
	header.text = "KEY_DOWNLOADING"
	b_cancel.msg = "KEY_CANCEL"
	b_close.msg = "KEY_CLOSE"

func _reset()->void:
	panel_download.visible = false
	panel_download.modulate.a = 0.0
	panel_result.visible = false
	panel_result.modulate.a = 0.0


func _in(_title:String)->void:
	header.text = tr("KEY_DOWNLOADING") + ": " + _title
	visible = true
	panel_download.visible = true
	panel_download.modulate.a = 1.0
	var _t:Tween = create_tween()
	_t.tween_property(self, "modulate:a", 1.0, 0.24)
	await _t.finished

func _out()->void:
	var _t:Tween = create_tween()
	_t.tween_property(self, "modulate:a", 0.0, 0.24)
	_t.tween_callback(
		func():
			visible = false
			panel_download.visible = false
			panel_download.modulate.a = 0.0
	)
	await _t.finished

func _on_error(_msg:String)->void:
	_download_failed()

func download_start(_l:CLOUD.GameLoader)->void:
	_loader = _l
	_loader.on_progress.connect(_on_progress)
	_loader.on_error.connect(_on_error)
	_on_progress(0.0, 0)
	await _in(_l.game_title)
	await get_tree().create_timer(0.6).timeout
	if !b_cancel.tap.is_connected(_on_cancel):
		b_cancel.tap.connect(_on_cancel)
	var _ok:bool = await _loader.download()
	if b_cancel.tap.is_connected(_on_cancel):
		b_cancel.tap.disconnect(_on_cancel)
	if _loader.canceled: return
	if _ok:
		_on_progress(progress.max_value, _loader.size_total)
		await get_tree().create_timer(0.6).timeout
		if X.games.keys().has(_loader.game_id):
			await X.game_update(_loader.game_id, _loader.game_version)
		else:
			await X.game_search()
		_download_success()
	else:
		_download_failed()


func _on_cancel()->void:
	b_cancel.tap.disconnect(_on_cancel)
	_loader.cancel()
	_download_canceled()

func _download_canceled()->void:
	var _t:Tween = create_tween()
	_t.tween_property(panel_download, "modulate:a", 0.0, 0.12)
	_t.tween_callback(
		func():
			panel_download.visible = false
			header_result.text = "KEY_DOWNLOAD_CANCELED"
			panel_result.visible = true
	)
	_t.tween_property(panel_result, "modulate:a", 1.0, 0.12)
	await _t.finished
	b_close.tap.connect(_close)

func _download_failed()->void:
	var _t:Tween = create_tween()
	_t.tween_property(panel_download, "modulate:a", 0.0, 0.12)
	_t.tween_callback(
		func():
			panel_download.visible = false
			header_result.text = "KEY_DOWNLOAD_FAILED"
			panel_result.visible = true
	)
	_t.tween_property(panel_result, "modulate:a", 1.0, 0.12)
	await _t.finished
	b_close.tap.connect(_close)

func _download_success()->void:
	var _t:Tween = create_tween()
	_t.tween_property(panel_download, "modulate:a", 0.0, 0.12)
	_t.tween_callback(
		func():
			panel_download.visible = false
			header_result.text\
			= _loader.game_title + " " + tr("KEY_DOWNLOADED")
			panel_result.visible = true
	)
	_t.tween_property(panel_result, "modulate:a", 1.0, 0.12)
	await _t.finished
	b_close.tap.connect(_close)

func _close()->void:
	if b_close.tap.is_connected(_close):
		b_close.tap.disconnect(_close)
	_loader.clear()
	_reset()
	await _out()

## listener
var _total_mb:float = 0.0
func bytes_to_mb(_b: int) -> float:
	return _b / 1048576.0

func _on_progress(_v:float, _sz:int)->void:
	if _total_mb <= 0.0: _total_mb = bytes_to_mb(_loader.size_total)
	progress.value = _v
	detail.text\
	= "%.1f / %.1f MB" % [bytes_to_mb(_sz), _total_mb]
