class_name Tower extends Area2D

enum CanonType {Mono, Double}
enum UnlockConditions {None, }
enum Type {Base}

signal dead(tower)

@export var damage : float = 4
@export var title : String = "Tower"
@export var type : Type = Type.Base
@export var cost : int = 40
@export var solidity : float = 5
@export var cooldown : float = .8
@export var canon_type : CanonType = CanonType.Mono
@export var unlock_condition : UnlockConditions = UnlockConditions.None
@export var unlock_description : String = "" 
@export var description : String = ""
@export var id : String = "tile249"
@export var projectile_speed : float = 4
@export var projectile_scene : PackedScene 
@export var initial_body_rotation : float = 0


@onready var body : Sprite2D = $"%Body"
@onready var base : Sprite2D = $"%Base"
@onready var hit_area : CollisionShape2D = $"%CollisionShape"
@onready var _range : Area2D = $"%Range"
@onready var projectile_starting : Sprite2D = $"%Projectile"
@onready var explosion_sprites : AnimatedSprite2D = $Explosion
@onready var lab_solidity : Label = $"%LabelSolidity"


var shoot_timer = 0
var peace_mode = false
var enemy : Tank = null
var cell : Vector2i
var frozen = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _aim_at_enemy()->Vector2:
	if is_instance_valid(enemy):
		var enemy_pos = enemy.hit_area.position + enemy.global_position
		var direction = (enemy_pos - global_position).normalized()
		var angle_to = body.transform.y.angle_to(-direction)
		body.rotate(angle_to)
		return direction
	else:
		body.rotation = deg_to_rad(initial_body_rotation)
	return Vector2.ZERO

func shoot(direction : Vector2)->void:
	AudioPlayer.play_sfx(AudioPlayer.SFX.TowerNormalShoot)
	var projectile : Projectile = projectile_scene.instantiate()
	projectile.speed = projectile_speed + 700
	projectile.direction = direction
	projectile.global_rotation = projectile_starting.global_rotation
	projectile_starting.add_child(projectile)
	var pos = projectile.position
	projectile_starting.remove_child(projectile)
	add_child(projectile)
	projectile.global_position = projectile_starting.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if frozen:
		return
		
	if not peace_mode:
		# Look for tanks
		enemy = null
		var rect = _range.get_child(0).shape.get_rect()
		rect.position += global_position
		for tank:Tank in get_tree().get_nodes_in_group("tank"):
			if rect.has_point(tank.hit_area.global_position):
				enemy = tank
				break
				
		var direction = _aim_at_enemy()
		
		# Handle shoots
		shoot_timer -= delta
		if shoot_timer <= 0 and is_instance_valid(enemy):
			shoot_timer = cooldown
			shoot(direction)
		
func explode()->void:
	AudioPlayer.play_sfx(AudioPlayer.SFX.TowerNormalExplosion)
	body.hide()
	base.hide()
	lab_solidity.hide()
	explosion_sprites.show()
	explosion_sprites.play("default")


func _on_sprite_animation_finished() -> void:
	hide()
	queue_free()

func take_damage(dmg:float)->void:
	solidity -= dmg
	lab_solidity.text = str(solidity)
	if solidity <= 0:
		dead.emit(self)
		explode()
