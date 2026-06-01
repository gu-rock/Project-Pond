class_name AudioDance extends Node

const BAR_CNT:int = 288 ## minimum = 8
const FREQ_MAX:float = 11050.0
const DB_MIN:int = 60

var spectrum:AudioEffectSpectrumAnalyzerInstance = null
var heights:Array[Height] = []

const _smooth:float = 0.16
var max_emiss:float = 1.2
var _nodes:Array[MeshInstance3D] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	for _i:int in BAR_CNT:
		heights.append(Height.new())


func start()->void:
	AudioServer.add_bus_effect(1, AudioEffectSpectrumAnalyzer.new())
	spectrum = AudioServer.get_bus_effect_instance(1, 0)
	process_mode = Node.PROCESS_MODE_ALWAYS
	for _i:int in BAR_CNT:
		var l_color:Color\
		= Color.from_hsv((BAR_CNT * 0.6 + _i * 0.5) / BAR_CNT, 0.5, 0.6)
		var _mat:StandardMaterial3D = _nodes[_i].get_surface_override_material(0)
		_mat.emission = l_color

func end()->void:
	process_mode = Node.PROCESS_MODE_DISABLED
	AudioServer.remove_bus_effect(1, 0)

func _process(_delta: float) -> void:
	_update()
	_beat()

func _update()->void:
	var l_prev_hz: float = 0.0
	for _i:int in BAR_CNT:
		var l_hz: float = (_i+1) * FREQ_MAX / BAR_CNT
		var l_mng:float\
		=spectrum.get_magnitude_for_frequency_range(l_prev_hz, l_hz).length()
		var l_energy:float\
		= clampf((DB_MIN + linear_to_db(l_mng)) / DB_MIN, 0,1)
		var l_height:float = l_energy * max_emiss * 10.0
		
		if l_height > heights[_i].high:
			heights[_i].high = l_height
		else:
			heights[_i].high = lerp(heights[_i].high, l_height, _smooth)
		
		if l_height <= 0.0:
			heights[_i].low = lerp(heights[_i].low, l_height, _smooth)
		
		heights[_i].actual = lerp(heights[_i].low, heights[_i].high, _smooth)
		l_prev_hz = l_hz

func _beat()->void:
	for _i:int in BAR_CNT:
		var _mat:StandardMaterial3D\
		= _nodes[_i].get_surface_override_material(0)
		_mat.emission_energy_multiplier\
		= clampf(heights[_i].actual, 0.24, max_emiss)
		_nodes[_i].position.y = heights[_i].actual


class Height:
	var high:float
	var low:float
	var actual:float
