class_name NewsCard extends PanelContainer

@onready var opts: HBoxContainer = $content/opts

@onready var cover: UI_ImageCloud = $cover
@onready var time: Label = $content/time
@onready var header: Label = $content/header
@onready var msg: Label = $content/msg

var file:Server.NewsFile = null

func _ready() -> void:
	opts.visible = false

func setup(_f:Server.NewsFile)->void:
	if _f == null: return
	file = _f
	time.text = XX.TIME.datetime(file.time)
	cover.load_images(file.image_links)
	set_texts()
	_set_butt()

func set_texts()->void:
	header.text = file.get_header(X.settings.language)
	msg.text = file.get_msg(X.settings.language)

func _set_butt()->void:
	if file.links.is_empty(): return
	opts.visible = true
	for _k:String in file.links.keys():
		var _b:UI_Butt_Text = UI_Butt_Text.LOAD_M().instantiate()
		opts.add_child(_b)
		_b.msg = _k
		_b.tap.connect(
			func(): C.open_link(file.links[_k])
		)
