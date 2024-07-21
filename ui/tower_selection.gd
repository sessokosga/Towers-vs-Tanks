extends Control

@onready var towers_parent = $"%Towers"
@onready var cost: Label = $"%Cost"
@onready var ctrl_description : Control = $"%Description"
@onready var ctrl_unlock : Control = $"%Unlock"
@onready var icon : TextureRect = $"%Icon"
@onready var title : Label = $"%Title"
@onready var canon_type : Label = $"%CanonType"
@onready var cooldown : Label = $"%Cooldown"
@onready var solidity : Label = $"%Solidity"
@onready var damage : Label = $"%Damage"
@onready var unlock_condition : Label = $"%UnlockCondition"


func _load_towers()->void:
	towers_parent.get_children().any(
		func (tb):
			if tb is TowerButton:
				var unlocked_towers = PlayerData.retreive_unlocked_towers()
				tb.disabled = not unlocked_towers.has(tb.id)
				tb.hovered.connect(_on_tower_button_hovered)
				tb.pressed_me.connect(_on_tower_button_pressed)
	)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ctrl_description.hide()
	ctrl_unlock.hide()
	_load_towers()
	TopUI.connect_to_back_button(_on_back_btn_pressed)
	TopUI.hide_loading_screen()
	TopUI.show_back_button()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tower_button_hovered(tb : TowerButton)->void:
	ctrl_description.hide()
	ctrl_unlock.hide()
	var tower = Tower.get_instance(tb.id)
	if tb.disabled:
		ctrl_unlock.show()
		unlock_condition.text = tower.unlock_description
	else:
		ctrl_description.show()
		title.text = tower.title
		cost.text = str("Cost : ",tower.cost)
		icon.texture = tower.icon
		canon_type.text = str("Canon type : ",Tower.get_string_type(tower.type))
		cooldown.text = str("Cooldown : ", tower.cooldown, "s")
		solidity.text = str("Solidity : ", tower.solidity)
		damage.text = (str("Damage : ",tower.damage))
	
func _on_tower_button_pressed(tb:TowerButton)->void:
	PlayerData.save_starting_towers([tb.id])
	TopUI.show_loading_screen()
	get_tree().change_scene_to_file("res://ui/game.tscn")

func _on_back_btn_pressed()->void:
	TopUI.show_loading_screen()
	get_tree().change_scene_to_file("res://ui/home.tscn")
