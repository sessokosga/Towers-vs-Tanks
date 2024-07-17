class_name Credits extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TopUI.hide_loading_screen()
	TopUI.connect_to_back_button(_on_back_btn_pressed)
	TopUI.show_back_button()
	pass

func _on_back_btn_pressed()->void:
	TopUI.show_loading_screen()
	get_tree().change_scene_to_file("res://ui/home.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
