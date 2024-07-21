extends Control

@onready var objects : TileMapLayer = $Objects
@onready var objects_backup : TileMapLayer = $ObjectsBackup

var used_objects : Array[Vector2i]

const MAX_TRIALS = 40

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_objects(15)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func add_objects(needed)->bool:
	objects.clear()
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
