extends Control

@onready var volume_master :HSlider  = $"%MasterVolume"
@onready var volume_music :HSlider  = $"%MusicVolume"
@onready var volume_sfx :HSlider  = $"%SFXVolume"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TopUI.hide_loading_screen()
	TopUI.connect_to_back_button(_on_back_btn_pressed)
	TopUI.show_back_button()
	
	volume_master.value = AudioPlayer.volume_master
	volume_music.value = AudioPlayer.volume_music
	volume_sfx.value = AudioPlayer.volume_sfx

func _on_back_btn_pressed()->void:
	TopUI.show_loading_screen()
	get_tree().change_scene_to_file("res://ui/home.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sfx_volume_value_changed(value: float) -> void:
	AudioPlayer.volume_sfx = value

func _on_master_volume_value_changed(value: float) -> void:
	AudioPlayer.volume_master = value

func _on_music_volume_value_changed(value: float) -> void:
	AudioPlayer.volume_music = value
