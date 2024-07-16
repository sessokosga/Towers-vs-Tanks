extends Control

@onready var tower_buttons :HBoxContainer = $"%TowerButtons"
@onready var level : Level = $"%BaseLevel"
@onready var towers_parent : Control = $"%TowersParent"
@onready var tanks_parent : Control = $"%TanksParent"

var tower_node =  preload("res://towers/tower.tscn")
var tank_node = preload("res://tanks/tank.tscn")

var occupied_cells : Array[Vector2i]=[]

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
		
func _deploy_tower(cell:Vector2i)->void:
	if occupied_cells.has(cell):
		return
	var tower = tower_node.instantiate()
	tower.global_position = (cell * 128) - Vector2i(25,30)
	towers_parent.add_child(tower)
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
	if tank.global_position != Vector2(-1,-1):
		tank.target = level.get_next_marker(tank.global_position)
	else:
		tank.queue_free()

func _spawn_tank()->Tank:
	var tank:Tank = tank_node.instantiate()
	tank.global_position = level.get_next_marker()
	tank.arrived.connect(_on_tank_reached_target)
	tank.target = level.get_next_marker(tank.global_position)
	return tank
