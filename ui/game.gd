extends Control

enum State {Playing, Pause, GameOver, Victory}

@onready var tower_buttons :HBoxContainer = $"%TowerButtons"
@onready var level : Level = $"%BaseLevel"
@onready var towers_parent : Control = $"%TowersParent"
@onready var tanks_parent : Control = $"%TanksParent"
@onready var lab_health : Label = $"%Health"
@onready var lab_money : Label = $"%Money"
@onready var lab_wave : Label = $"%Wave"
@onready var screeen_gameover : Control = $"%GameOver"
@onready var screeen_pause : Control = $"%Pause"
@onready var screeen_victory : Control = $"%Victory"
@onready var screeen_base : Control = $"%BaseScreen"

var tower_node =  preload("res://towers/tower.tscn")
var tank_node = preload("res://tanks/tank.tscn")

var selected_tower_button :TowerButton = null
var occupied_cells : Array[Vector2i]=[]
var peace_mode = false
var spawned_tanks = 0
var wave_started = false
var spanw_tank_timer_max = 1.8
var spanw_tank_timer = 0

var current_wave : int:
	set(v):
		current_wave = v
		if not is_instance_valid(lab_wave):
			return
		lab_wave.text = str("Wave : ",v+1)

var current_state : State :
	set(s):
		current_state = s
		_handle_state_changes()
		
var health : 
	set(v):
		health = v
		if health <= 0:
			health = 0
			current_state = State.GameOver
		if not is_instance_valid(lab_health):
			return
		lab_health.text = str("Health : ", health)
		
var money : 
	set(v):
		money = v
		lab_money.text = str("Money : ", money)
		_check_afordable_towers()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TopUI.hide_loading_screen()
	current_state = State.Playing
	health = 20
	money = 250
	current_wave = 0
	_start_wave()
	for tb : TowerButton in tower_buttons.get_children():
		tb.toggled_it.connect(_on_tower_button_toggled)
	
	
func _on_tower_button_toggled(tb:TowerButton)->void:
	if tb.button_pressed:
		selected_tower_button = tb
		level.show_tower_places()

func _tower_button_unpress()->void:
	selected_tower_button = null
	for tb : TowerButton in tower_buttons.get_children():
		tb.button_pressed = false
		
func _on_tower_destroyed(tower:Tower)->void:
	var idx = occupied_cells.find(tower.cell)
	if idx != -1:
		occupied_cells.remove_at(idx)
		
func _deploy_tower(cell:Vector2i)->void:
	if occupied_cells.has(cell) or not is_instance_valid(selected_tower_button):
		return
	var tower = tower_node.instantiate()
	tower.cell = cell
	tower.global_position = (cell * 128) + Vector2i(25,38)
	towers_parent.add_child(tower)
	tower.dead.connect(_on_tower_destroyed)
	occupied_cells.append(cell)
	money -= selected_tower_button.cost

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state == State.Pause:
		return
	
	if wave_started and spawned_tanks < level.TANKS_PER_WAVE[current_wave] :
		spanw_tank_timer -= delta
		if spanw_tank_timer <=0:
			spanw_tank_timer = spanw_tank_timer_max
			var tank = _spawn_tank()
			tanks_parent.add_child(tank)
			spawned_tanks += 1
	
	# Check if the player clicks 
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var cell = level.hovered_tower_place()
		if cell != Vector2i(-1,-1):
			_deploy_tower(cell)
		
		_tower_button_unpress()
		level.hide_tower_places()
		
func _on_tank_reached_target(tank:Tank)->void:
	tank.target = level.get_next_marker(tank.global_position)
	if tank.target == Vector2(-1,-1):
		health -= 1
		tank.queue_free()
		check_wave_completion()
		
func _on_tank_destroyed(tank)->void:
	money += 50

func _spawn_tank()->Tank:
	var tank:Tank = tank_node.instantiate()
	tank.global_position = level.get_next_marker()
	tank.arrived.connect(_on_tank_reached_target)
	tank.dead.connect(_on_tank_destroyed)
	tank.target = level.get_next_marker(tank.global_position)
	check_wave_completion()
	return tank
	
func _check_afordable_towers()->void:
	for tb:TowerButton in tower_buttons.get_children():
		tb.disabled = money < tb.cost
		
func _set_peace(enabled):
	peace_mode = enabled
	for tank:Tank in tanks_parent.get_children():
		tank.peace_mode = enabled
	for tower:Tower in towers_parent.get_children():
		tower.peace_mode = enabled
		
func _set_frozen(enabled):
	for tank:Tank in tanks_parent.get_children():
		tank.frozen = enabled
	for tower:Tower in towers_parent.get_children():
		tower.frozen = enabled
	
func _handle_state_changes()->void:
	_set_peace(true)
	_set_frozen(false)
	screeen_base.hide()
	screeen_gameover.hide()
	screeen_pause.hide()
	screeen_victory.hide()
	match current_state:
		State.Playing:
			_set_peace(false)
			_set_frozen(false)
		State.Pause:
			_set_frozen(true)
			screeen_base.show()
			screeen_pause.show()
		State.GameOver:
			screeen_base.show()
			screeen_gameover.show()
		State.Victory:
			screeen_base.show()
			screeen_victory.show()


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_home_pressed() -> void:
	TopUI.show_loading_screen()
	get_tree().change_scene_to_file("res://ui/home.tscn")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		current_state = State.Pause

func _on_resume_pressed() -> void:
	current_state = State.Playing
	
func _start_wave():
	if current_wave < level.max_waves:
		spawned_tanks = 0
		spanw_tank_timer = 0
		wave_started = true

func check_wave_completion()->void:
	if spawned_tanks >= level.TANKS_PER_WAVE[current_wave] \
		and tanks_parent.get_child_count() <= 0:
			if current_wave < level.max_waves -1:
				current_wave += 1
				_start_wave()
			else:
				if health > 0:
					current_state = State.Victory


func _on_tanks_parent_child_order_changed() -> void:
	check_wave_completion()
