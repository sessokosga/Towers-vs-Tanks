extends Control

enum State {Playing, Pause, GameOver, WaveCompleted, Victory}

@onready var tower_buttons :HBoxContainer = $"%TowerButtons"
@onready var level : Level = $"%BaseLevel"
@onready var towers_parent : Control = $"%TowersParent"
@onready var tanks_parent : Control = $"%TanksParent"
@onready var rewards_parent : HBoxContainer = $"%RewardsParent"
@onready var lab_health : Label = $"%Health"
@onready var lab_money : Label = $"%Money"
@onready var lab_wave : Label = $"%Wave"
@onready var screeen_gameover : Control = $"%GameOver"
@onready var screeen_wave_completed : Control = $"%WaveCompleted"
@onready var screeen_pause : Control = $"%Pause"
@onready var screeen_victory : Control = $"%Victory"
@onready var screeen_base : Control = $"%BaseScreen"
@onready var btn_next_wave : Button = $"%NextWave"


var tank_node = load("res://tanks/tank.tscn")

var starting_towers : Array = []
var unlocked_towers : Array = []
var selected_reward : Reward = null
var selected_tower_button :TowerButton = null
var occupied_cells : Array[Vector2i]=[]
var rewards_list : Array[Reward]=[]
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
	unlocked_towers = PlayerData.retreive_unlocked_towers()
	starting_towers = PlayerData.retreive_starting_towers()
	
	health = 20
	money = 250
	current_wave = 0
	_start_wave()
	for tb : TowerButton in tower_buttons.get_children():
		tb.toggled_it.connect(_on_tower_button_toggled)
	_load_starting_towers()
	_load_rewards()
	
	TopUI.hide_loading_screen()
	current_state = State.WaveCompleted
	
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
	var tower : Tower = Tower.get_instance(selected_tower_button.id)
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
		AudioPlayer.play_sfx(AudioPlayer.SFX.HealthReduced)
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
	if not is_instance_valid(screeen_base):
		return
	_set_peace(true)
	_set_frozen(false)
	screeen_base.hide()
	screeen_gameover.hide()
	screeen_pause.hide()
	screeen_victory.hide()
	screeen_wave_completed.hide()
	match current_state:
		State.Playing:
			_set_peace(false)
			_set_frozen(false)
		State.Pause:
			_set_frozen(true)
			screeen_base.show()
			screeen_pause.show()
		State.WaveCompleted:
			AudioPlayer.play_ui(AudioPlayer.UI.Confirm)
			_set_frozen(true)
			screeen_base.show()
			screeen_wave_completed.show()
		State.GameOver:
			screeen_base.show()
			screeen_gameover.show()
		State.Victory:
			AudioPlayer.play_ui(AudioPlayer.UI.RewardUnlocked)
			screeen_base.show()
			screeen_victory.show()

func _on_restart_pressed() -> void:
	AudioPlayer.play_ui(AudioPlayer.UI.Select)
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	AudioPlayer.play_ui(AudioPlayer.UI.Select)
	TopUI.show_loading_screen()
	get_tree().change_scene_to_file("res://ui/home.tscn")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		AudioPlayer.play_ui(AudioPlayer.UI.Select)
		current_state = State.Pause

func _on_resume_pressed() -> void:
	AudioPlayer.play_ui(AudioPlayer.UI.Select)
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
				
				current_state = State.WaveCompleted
			else:
				if health > 0:
					current_state = State.Victory

func _on_tanks_parent_child_order_changed() -> void:
	check_wave_completion()

func _on_next_wave_pressed() -> void:
	current_state = State.Playing
	current_wave += 1
	_apply_reward()
	_start_wave()
	btn_next_wave.disabled = true

func _on_texture_button_pressed() -> void:
	AudioPlayer.play_ui(AudioPlayer.UI.Select)
	current_state = State.Pause
	
func _on_reward_active(rwd:Reward)->void:
	btn_next_wave.disabled = false
	selected_reward = rwd
	AudioPlayer.play_ui(AudioPlayer.UI.Select)
	for rw : Reward in rewards_parent.get_children():
		if rwd != rw:
			rw.selected = false
	
func _load_rewards()->void:
	var dir_path = "res://rewards/rewards"
	var files = DirAccess.open(dir_path)
	for file in files.get_files():
		var reward_node :PackedScene = load(str(dir_path,'/',file))
		
		var reward : Reward = reward_node.instantiate()
		if reward.type == Reward.Type.Tower:
			if unlocked_towers.has(reward.id) and not starting_towers.has(reward.id):
				reward.active.connect(_on_reward_active)
				rewards_parent.add_child(reward)
		else:
			reward.active.connect(_on_reward_active)
			rewards_parent.add_child(reward)
	
func _add_rewards(num)->void:
	var trials = 0
	const MAX_TRIALS = 40
	var found = 0
	while  found < num and trials < MAX_TRIALS:
		var reward
		 
func _apply_reward()->void:
	AudioPlayer.play_ui(AudioPlayer.UI.Confirm)
	selected_reward.hide()
	match selected_reward.effect:
		Reward.Effect.AddTwoTowerPlace:
			level.add_tower_places(2) 
			#if not level.is_empty_spot_available:
				#selected_reward.removed = true
		Reward.Effect.AddTwoHealthPoints:
			health += 2
		Reward.Effect.AddThousandCoins:
			money += 1000
		Reward.Effect.SingleCanon:
			_check_afordable_towers()
			_add_tower_type(Tower.Type.Base)
			selected_reward.removed = true
		Reward.Effect.DoubleCanon:
			_check_afordable_towers()
			_add_tower_type(Tower.Type.DoubleCanon)
			selected_reward.removed = true
		Reward.Effect.SingleMissile:
			_check_afordable_towers()
			_add_tower_type(Tower.Type.SingleMissile)
			selected_reward.removed = true
		#Reward.Effect.OpenSingleMissile:
			#tb_open_single_missile.disabled = false
			#tb_open_single_missile.show()
			#check_tower_purchase_availabity()
			#selected_reward.removed = true
		#Reward.Effect.OpenDoubleMissile:
			#tb_open_double_missile.disabled = false
			#tb_open_double_missile.show()
			#check_tower_purchase_availabity()
			#selected_reward.removed = true
		#Reward.Effect.ClosedDoubleMissile:
			#tb_closed_double_missile.disabled = false
			#tb_closed_double_missile.show()
			#check_tower_purchase_availabity()
			#selected_reward.removed = true

func _add_tower_type(type:Tower.Type)->void:
	tower_buttons.get_children().any(
		func (tb:TowerButton):
			if tb.type == type:
				tb.show()
	)

func _load_starting_towers()->void:
	tower_buttons.get_children().any(func(tb): tb.hide())
	for id in starting_towers:
		for tb : TowerButton in tower_buttons.get_children():
			if tb.id == id:
				tb.show()
			
