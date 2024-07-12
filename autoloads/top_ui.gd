extends CanvasLayer

@onready var loading_screen : Control = $"%LoadingScreen"
@onready var back_btn : Button = $"%BackBtn"

func show_loading_screen()->void:
	back_btn.hide()
	loading_screen.show()

func hide_loading_screen()->void:
	loading_screen.hide()
	
func show_back_button()->void:
	back_btn.show()
	
func hide_back_button()->void:
	back_btn.hide()
	
func connect_to_back_button(callback:Callable)->void:
	back_btn.pressed.connect(callback)
	
func hide_all()->void:
	loading_screen.hide()
	back_btn.hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_all()
