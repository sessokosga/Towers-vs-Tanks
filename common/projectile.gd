class_name Projectile extends Area2D

enum Target {Tank, Tower}

@export var from : Target 
@export var to : Target

@onready var collision_shape : CollisionShape2D = $"%CollisionShape"
@onready var body : Sprite2D = $"%Body"

var speed : float
var direction : Vector2
var screen_size : Vector2
var damage : float = 1 
var ignore = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_area_entered(area:Area2D)->void:
	if area is Tower and from == Target.Tank and to == Target.Tower and not ignore:
		area.take_damage(damage)
		ignore = true
		hide()
		queue_free()

func _on_body_entered(body:Node2D)->void:
	if body is Tank and from == Target.Tower and to == Target.Tank and not ignore:
		body.take_damage(damage)
		ignore = true
		hide()
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += direction * speed * delta 
	
	#if collision_shape.shape.get_rect().has_point()
	
	if global_position.x - body.texture.get_width()/2 < 0 or global_position.x + body.texture.get_width()/2 > screen_size.x or \
	global_position.y - body.texture.get_height()/2 <0 or global_position.y + body.texture.get_height()/2 > screen_size.y :
		queue_free()
