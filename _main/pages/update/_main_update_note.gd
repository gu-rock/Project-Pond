class_name MainMenu_Update_Note extends PanelContainer

@onready var msg: Label = $msg

func set_note(_msg:String)->void:
	msg.text = _msg
