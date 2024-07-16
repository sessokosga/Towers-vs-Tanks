extends Control

@onready var tower_buttons :HBoxContainer = $"%TowerButtons"
@onready var level : Level = $"%BaseLevel"
@onready var towers_parent : Control = $"%TowersParent"

var tower_node =  preload("res://towers/tower.tscn")
var occupied_cells : Array[Vector2i]=[]

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
	# Check if the player clicks 
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var cell = level.hovered_tower_place()
		if cell != Vector2i(-1,-1):
			_deploy_tower(cell)
		
		_tower_button_unpress()
		level.hide_tower_places()
