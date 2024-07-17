extends Control

enum State {Playing, Pause, GameOver, Victory}

@onready var tower_buttons :HBoxContainer = $"%TowerButtons"
@onready var level : Level = $"%BaseLevel"
@onready var towers_parent : Control = $"%TowersParent"
@onready var tanks_parent : Control = $"%TanksParent"
@onready var lab_health : Label = $"%Health"
@onready var lab_money : Label = $"%Money"
@onready var screeen_gameover : Control = $"%GameOver"
@onready var screeen_pause : Control = $"%Pause"
@onready var screeen_victory : Control = $"%Victory"
@onready var screeen_base : Control = $"%BaseScreen"

var tower_node =  preload("res://towers/tower.tscn")
var tank_node = preload("res://tanks/tank.tscn")

var selected_tower_button :TowerButton = null
var occupied_cells : Array[Vector2i]=[]
var peace_mode = false
var current_state : State :
	set(s):
		current_state = s
		_handle_state_changes()
		
var health : 
	set(v):
		health = v
		lab_health.text = str("Health : ", health)
		if health <= 0:
			health = 0
			current_state = State.GameOver
		
var money = 400 : 
	set(v):
		money = v
		lab_money.text = str("Money : ", money)
		_check_afordable_towers()


var spanw_tank_timer = .8
var timer = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_state = State.Playing
	health = 20
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
	occupied_cells.remove_at(occupied_cells.find(tower.cell))
		
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
		
	timer -= delta
	if timer <=0:
		timer = spanw_tank_timer
		var tank = _spawn_tank()
		tanks_parent.add_child(tank)
	
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
		
func _on_tank_destroyed(tank)->void:
	money += 50

func _spawn_tank()->Tank:
	var tank:Tank = tank_node.instantiate()
	tank.global_position = level.get_next_marker()
	tank.arrived.connect(_on_tank_reached_target)
	tank.dead.connect(_on_tank_destroyed)
	tank.target = level.get_next_marker(tank.global_position)
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
	_set_frozen(true)
	screeen_base.hide()
	screeen_gameover.hide()
	screeen_pause.hide()
	screeen_victory.hide()
	match current_state:
		State.Playing:
			_set_peace(false)
			_set_frozen(false)
		State.Pause:
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
