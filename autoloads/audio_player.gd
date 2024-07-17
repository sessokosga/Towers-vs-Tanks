extends Node

enum SFX{
	TankNormalExplosion,
	TankHugeExplosion,
	TankBigExplosion,
	TankMedExplosion,
	TankShootNormal,
	TankShootBig,
	TowerNormalExplosion,
	TowerNormalShoot,
	TowerMissilelShoot,
	HealthReduced
}

enum UI {
	Select,
	Confirm,
	RewardUnlocked
}


enum Music{
}

@export var music_enabled = false :
	set(val):
		music_enabled = val
		if music_enabled:
			play_random_loop()
		else:
			stop_music_loop()

# UI
const ui_select = preload("res://ui/assets/audio/sfx/Analog Synthesized UI - Button Click Tone 1.wav")
const ui_confirm = preload("res://ui/assets/audio/sfx/Success 2a.wav")
const ui_reward = preload("res://ui/assets/audio/sfx/The Chris Alan - 8-Bit SFX & UI - Eerie Notification 10.wav")

# Music

# SFX
const tank_normal_explosion = preload("res://tanks/assets/audio/sfx/DeepExplosion02.wav")
const tank_huge_explosion = preload("res://tanks/assets/audio/sfx/BigExplosion02.wav")
const tank_large_explosion = preload("res://tanks/assets/audio/sfx/explosion_med_long_tail_01.wav")
const tank_big_explosion = preload("res://tanks/assets/audio/sfx/Explosion 8.wav")
const tank_shoot_normal = preload("res://tanks/assets/audio/sfx/gun_pistol_shot_silenced_04.wav")
const tank_shoot_big = preload("res://tanks/assets/audio/sfx/gun_silenced_sniper1_shot_01.wav")
const tower_normal_explosion = preload("res://towers/assets/audio/sfx/DeepExplosion02.wav")
const tower_normal_shoot = preload("res://towers/assets/audio/sfx/Assault Rifle - M4 - 03 - Burst 03.wav")
const tower_missile_shoot = preload("res://towers/assets/audio/sfx/Cocking_11.wav")
const  health_reduced = preload("res://towers/assets/audio/sfx/Explosive Hit 10 Filtered, Low End.wav")

var volume_master : float = -24
var volume_sfx : float = 0
var volume_music : float = 0

var current_music_loop_id : Music
var current_music_loop : AudioStreamPlayer = null

var diying_volume : float
var diying_music : AudioStreamPlayer 
var rising_music : AudioStreamPlayer 
var rising_volume : float

var played_loops =[]

func _ready() -> void:
	randomize()
	#if music_enabled:
		#play_music(Music.DeadWalking,true)

func play_ui(id:UI,looping=false)->bool:
	if music_enabled == false:
		return false
	var stream 
	match id:
		UI.Select:
			stream = ui_select
		UI.Confirm:
			stream = ui_confirm
		UI.RewardUnlocked:
			stream = ui_reward
		_:
			push_error("UI sound ",id," not found")
			return false
			
	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	asp.name = "UI "
	if volume_master > volume_sfx:
		asp.volume_db = volume_sfx
	else:
		asp.volume_db = volume_master
	add_child(asp)
	asp.play()
	
	asp.finished.connect(
		func()->void:
			if looping:
				asp.stream_paused = false
				asp.play()
			else:
				asp.queue_free()
			
			)
	return true

func play_sfx(id:SFX,looping=false)->bool:
	if music_enabled == false:
		return false
	var asp = AudioStreamPlayer.new()
	asp.name = "SFX "
	if volume_master > volume_sfx:
		asp.volume_db = volume_sfx
	else:
		asp.volume_db = volume_master
	var stream 
	match id:
		SFX.TankNormalExplosion:
			stream = tank_normal_explosion
		SFX.TankBigExplosion:
			stream = tank_big_explosion
		SFX.TankHugeExplosion:
			stream = tank_huge_explosion
		SFX.TankMedExplosion:
			stream = tank_large_explosion
		SFX.TankShootNormal:
			stream = tank_shoot_normal
		SFX.TankShootBig:
			stream = tank_shoot_big
		SFX.TowerNormalExplosion:
			stream = tower_normal_explosion
		SFX.TowerMissilelShoot:
			stream = tower_missile_shoot
		SFX.TowerNormalShoot:
			stream = tower_normal_shoot
		SFX.HealthReduced:
			asp.volume_db += linear_to_db(10)
			stream = health_reduced
		_:
			push_error("SFX ",id," not found")
			return false
			
	
	asp.stream = stream
		
	add_child(asp)
	asp.play()
	
	asp.finished.connect(
		func()->void:
			if looping:
				asp.stream_paused = false
				asp.play()
			else:
				asp.queue_free()
			
			)
	return true

func play_random_loop():
	if music_enabled == false or is_instance_valid(current_music_loop) and current_music_loop.playing:
		return false
	#var id = randi() % Music.size()
	"""
	var trials = 0
	if played_loops.size() == Music.size():
		played_loops = []
	while played_loops.has(id) and trials < 100:
		id = randi() % Music.size()
		trials += 1
	played_loops.append(id)
	"""
	#current_music_loop = play_music(Music.DeadWalking)
	
func play_music(id:Music,looping = false)->AudioStreamPlayer:
	if music_enabled == false:
		return null
	var loop
	
	#match id:
		#Music.DeadWalking:
			#loop = dead_walking
		#_:
			#push_error("Music ",id," not found")
			#return null
	var asp = AudioStreamPlayer.new()
	asp.stream = loop
	#asp.volume_db = linear_to_db(0)
	asp.name = "Music Loop"
	if volume_master > volume_sfx:
		asp.volume_db = volume_sfx
	else:
		asp.volume_db = volume_master
	add_child(asp)
	asp.play()
	#rising_music = asp
	asp.finished.connect(
		func():
			if looping:
				asp.stream_paused = false
				asp.play()
			else:
				play_random_loop()
	)
	return asp

func stop_music_loop()->bool:
	if current_music_loop.playing:
		diying_music = current_music_loop
		diying_volume = db_to_linear(diying_music.volume_db)
		return true
	return false
	

func _process(_delta: float) -> void:
	if is_instance_valid(diying_music):
		if diying_volume <= 0:
			diying_music.stop()
			remove_child(diying_music)
			diying_music.queue_free()
		else:
			diying_volume -= .01
			diying_music.volume_db = linear_to_db( diying_volume)
			
		
	
	if is_instance_valid(rising_music):
		if db_to_linear(rising_music.volume_db) < 1:
			rising_music.volume_db = linear_to_db( db_to_linear(rising_music.volume_db) + .008)
			if db_to_linear(rising_music.volume_db) >1:
				rising_music.volume_db = linear_to_db(1)
