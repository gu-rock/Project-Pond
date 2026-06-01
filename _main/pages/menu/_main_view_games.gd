class_name MainMenu_Games extends MainMenu.View

@onready var grid: GridContainer = $grid
@onready var empty: Label = $grid/empty
var _cards:Array[GameCard] = []
var _card_sz:float = 492.0

func _exit_tree() -> void:
	if X.on_games_update.is_connected(_on_games_update):
		X.on_games_update.disconnect(_on_games_update)

func _on_games_update()->void:
	for _c:GameCard in _cards:
		if _c != null: _c.queue_free()
	if !X.games.is_empty():
		empty.visible = false
		_spawn_cards()
	else:
		empty.visible = true
	_sizing()

func _ready() -> void:
	self.draw.connect(_sizing)
	X.on_games_update.connect(_on_games_update)
	modulate.a = 0.0
	empty.visible = false

func setup(_online:bool)->void:
	_on_games_update()
	await get_tree().create_timer(0.12).timeout

func on_open()->void:
	_sizing()

func on_close()->void:
	pass

func _sizing()->void:
	var _cur_rat:float = self.size.x/_card_sz
	if int(_cur_rat) != grid.columns: _sizing_anim(int(_cur_rat))
	#if int(_cur_rat) != grid.columns and grid.columns > 1:
		#_sizing_anim(int(_cur_rat))

var _t:Tween = null
func _sizing_anim(_s:int)->void:
	if _t: _t.kill()
	_t = create_tween()
	_t.tween_property(grid, "modulate:a" , 0.0, 0.12)
	_t.tween_callback(
		func():
			grid.columns = _s
	)
	_t.tween_interval(0.06)
	_t.tween_property(grid, "modulate:a" , 1.0, 0.24)


const _CARD_PACK:Resource = preload("uid://bhb36y8g0kc77")
func _spawn_cards()->void:
	var _m:MainMenu = get_parent()
	for _g:GameInfo in X.games.values():
		var _c:GameCard = _CARD_PACK.instantiate()
		grid.add_child(_c)
		_c.set_info(_g,_m)
		_cards.append(_c)
