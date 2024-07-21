class_name Level extends Control

@onready var tower_places : TileMapLayer = $TowerPlaces
@onready var tower_places_backup : TileMapLayer = $TowerPlacesBackup
@onready var objects : TileMapLayer = $Objects
@onready var objects_backup : TileMapLayer = $ObjectsBackup
@onready var hovered : TileMapLayer = $Hovered
@onready var hovered_backup : TileMapLayer = $HoveredBackup
@onready var path : Control = $Paths

@export var starting_places = 10
@export var starting_objects = 10
@export var max_waves = 10

const MAX_TRIALS = 40
const TANKS_PER_WAVE = [4,6,8,4,6,8,4,6,8,10] #[6,8,10,6,8,10,6,8,10,14]

var used_objects : Array[Vector2i]
var used_tower_places : Array[Vector2i]

func hide_tower_places()->void:
	tower_places.hide()
	
func show_tower_places()->void:
	tower_places.show()

func add_tower_places(needed)->bool:
	var trials = 0
	var MAX_TRIALS = 40
	var found = 0
	var tower_places_cells = tower_places_backup.get_used_cells()
	while found  < needed and trials < MAX_TRIALS:
		var cell : Vector2i = tower_places_cells.pick_random()
		if used_tower_places.has(cell):
			trials += 1 
		else:
			found += 1
			used_tower_places.append(cell)
			tower_places.set_cell(cell,tower_places_backup.get_cell_source_id(cell),tower_places_backup.get_cell_atlas_coords(cell))
	return found == needed

func add_objects(needed)->bool:
	var trials = 0
	var found = 0
	var objects_cells = objects_backup.get_used_cells()
	while found  < needed and trials < MAX_TRIALS:
		var cell : Vector2i = objects_cells.pick_random()
		if used_objects.has(cell):
			trials += 1 
		else:
			found += 1
			used_objects.append(cell)
			objects.set_cell(cell,objects_backup.get_cell_source_id(cell),objects_backup.get_cell_atlas_coords(cell))
	return found == needed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	hide_tower_places()
	objects_backup.hide()
	objects.clear()
	tower_places_backup.hide()
	tower_places.clear()
	add_tower_places(starting_places)
	add_objects(starting_objects)
	
func hovered_tower_place()->Vector2i:
	var cell = hovered.local_to_map(hovered.get_local_mouse_position())
	if hovered.get_cell_atlas_coords(cell) != Vector2i(-1,-1):
		return cell
	return Vector2i(-1,-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Hower efect over tower places
	hovered.clear()
	if tower_places.visible:
		var cell = tower_places.local_to_map(tower_places.get_local_mouse_position())
		if tower_places.get_cell_atlas_coords(cell) != Vector2i(-1,-1):
			hovered.set_cell(cell,hovered_backup.get_cell_source_id(cell),hovered_backup.get_cell_atlas_coords(cell))
	
func get_next_marker(pos:Vector2 = Vector2(-1,-1))->Vector2:
	if pos == Vector2(-1,-1):
		return path.get_child(0).global_position
	
	var paths_pos = path.get_children()
	var i = 0
	while i < paths_pos.size():
		var mk:Marker2D = paths_pos[i]
		if mk.global_position != pos:
			i += 1
		else:
			break
	
	if i >= paths_pos.size()-1:
		return Vector2(-1,-1)
	else:
		return paths_pos[i+1].global_position
