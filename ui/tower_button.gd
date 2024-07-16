@tool
extends TextureButton
class_name TowerButton

@onready var lab_cost = $"%Cost"

signal toggled_it(tb)
signal pressed_me(tb)

@export var type : Tower.Type
@export var cost:int:
	set(v):
		cost = v
		if not is_instance_valid(lab_cost):
			return
		lab_cost.text = str(cost)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cost = cost


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_toggled(toggled_on: bool) -> void:
	toggled_it.emit(self)


func _on_pressed() -> void:
	pressed_me.emit(self)
