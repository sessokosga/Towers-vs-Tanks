extends Control

@onready var tower_buttons :HBoxContainer = $"%TowerButtons"
@onready var level : Level = $"%BaseLevel"
@onready var towers_parent : Control = $"%TowersParent"
@onready var tanks_parent : Control = $"%TanksParent"
@onready var lab_health : Label = $"%Health"

var tower_node =  preload("res://towers/tower.tscn")
var tank_node = preload("res://tanks/tank.tscn")

var occupied_cells : Array[Vector2i]=[]
var health = 20 : 
	set(v):
		health = v
		lab_health.text = str("health : ", health)

var spanw_tank_timer = .8
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for tb : TowerButton in tower_buttons.get_children():
		tb.toggled_it.connect(_on_tower_button_toggled)
	
	
func _on_tower_button_toggled(tb:TowerButton)->void:
	if tb.button_pressed:
		level.show_tower_places()

func _tower_button_unpress()->void:
	for tb : TowerButton in tower_buttons.get_children():
		tb.button_pressed = false
		
func _on_tower_destroyed(tower:Tower)->void:
	occupied_cells.remove_at(occupied_cells.find(tower.cell))
		
func _deploy_tower(cell:Vector2i)->void:
	if occupied_cells.has(cell):
		return
	var tower = tower_node.instantiate()
	tower.cell = cell
	tower.global_position = (cell * 128) + Vector2i(25,38)
	towers_parent.add_child(tower)
	tower.dead.connect(_on_tower_destroyed)
	occupied_cells.append(cell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
		print(health)
		tank.queue_free()

func _spawn_tank()->Tank:
	var tank:Tank = tank_node.instantiate()
	tank.global_position = level.get_next_marker()
	tank.arrived.connect(_on_tank_reached_target)
	tank.target = level.get_next_marker(tank.global_position)
	return tank
