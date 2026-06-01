class_name MainScreen_BG extends Node3D

@export var _material:StandardMaterial3D = null

var _clr_nor:Color =  Color("0c0c0c")

var _meshes:Array[MeshInstance3D] = []

@onready var _2: Node3D = $"2"
@onready var msg: Label3D = $camera/msg
@onready var audio_dance: AudioDance = $audio_dance



func _ready() -> void:
	_material.albedo_color = _clr_nor
	_material.emission = THEME.COLOR_AC
	_material.emission_energy_multiplier = 0.0
	msg.modulate.a = 0.0
	msg.text = "KEY_WAIT"
	for _m:Node in _2.get_children():
		_m.set_surface_override_material(0, _material.duplicate())
		_meshes.append(_m)

var _t: Tween = null
func loading_start()->void:
	if _t: _t.kill()
	_t = create_tween()
	_t.tween_property(msg, "modulate:a", 1.0, 0.36)
	await _t.finished
	_idle()

func _idle()->void:
	if _t: _t.kill()
	_t = create_tween().set_loops()
	_t.tween_property(msg, "modulate:a", 0.6, 0.6)
	_t.tween_property(msg, "modulate:a", 1.0, 0.9)

func loading_end()->void:
	if _t: _t.kill()
	_t = create_tween()
	_t.tween_property(msg, "modulate:a", 0.0, 0.36)
	_t.tween_interval(0.12)
	await _t.finished

func dance()->void:
	var _mats:Array[StandardMaterial3D] = []
	for _i:int in audio_dance.BAR_CNT:
		var _pk:MeshInstance3D = _meshes.pick_random()
		_mats.append(_pk.get_surface_override_material(0))
	audio_dance._nodes.append_array(_meshes)
	audio_dance.start()
