class_name MainMenu_Update extends MainScreen.Page

@onready var header: Label = $topbar/l_bar/header
@export var _note_pack:PackedScene = null
@onready var note_list: VBoxContainer = $content/list
@onready var r_bar: HBoxContainer = $topbar/r_bar
@onready var b_offline: UI_Butt_Text = $topbar/l_bar/b_offline



func _onset()->void:
	if main.version_note == null:
		main.version_note = await C.version_note_get(C.VERSION)
	
	if main.version_note == null:
		main.page_switch(main.Pages.MENU)
		return
	
	for _lnk:String in main.version_note.download_links.keys():
		var _b:UI_Butt_Text = UI_Butt_Text.LOAD_M().instantiate()
		r_bar.add_child(_b)
		_b.msg = _lnk
		_b.tap.connect(
			func(): C.open_link(main.version_note.download_links[_lnk])
		)
	_set_msg()
	b_offline.tap.connect(p_offline)

func _set_msg()->void:
	b_offline.msg = tr("KEY_LATER")
	var _nt:Dictionary = main.version_note.get_note(X.settings.language)
	header.text = tr("KEY_CAN_UPADTE") + ": " + XX.TIME.stamp_to_version(main.version_note.version)
	var _crd:MainMenu_Update_Note = _note_pack.instantiate()
	note_list.add_child(_crd)
	var _msg:String = ""
	for _h in _nt.keys():
		_msg += _h + "\n"
		for _s in _nt[_h]:
			_msg += "   - " + _s + "\n"
	
	_crd.set_note(_msg)


## Buttons
func p_offline()->void:
	main.page_switch(main.Pages.MENU)
