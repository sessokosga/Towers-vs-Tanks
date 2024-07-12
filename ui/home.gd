extends Control


@onready var home : Control = $"%Home"

enum ScreenState {Home, Credits, Play, Upgrade}
var current_screen:ScreenState :
	set(new_state):
		_change_state(new_state)
		current_screen = new_state

# Handle Screen state changes
func _change_state(new_state : ScreenState)->void:
	TopUI.hide_all()
	home.hide()
	match new_state:
		ScreenState.Credits:
			TopUI.show_loading_screen()
			get_tree().change_scene_to_file("res://ui/credits.tscn")
		ScreenState.Home:
			home.show()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_screen = ScreenState.Home
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	pass # Replace with function body.


func _on_upgrade_pressed() -> void:
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	current_screen = ScreenState.Credits


func _on_quit_pressed() -> void:
	get_tree().quit(0)


func _on_back_pressed() -> void:
	pass # Replace with function body.
