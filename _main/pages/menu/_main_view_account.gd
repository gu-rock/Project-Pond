class_name MenuAccount extends MainMenu.View

func setup(_online:bool)->void:
	await get_tree().create_timer(0.12).timeout
func on_open()->void: pass
func on_close()->void: pass


@onready var _note_not_available: Label = $list/soon

func _ready() -> void:
	X.on_language.connect(_on_lang)
	_on_lang()

func _on_lang()->void:
	_note_not_available.text = tr("KEY_NOT_AVAILABLE")
