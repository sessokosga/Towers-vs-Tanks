class_name Tank extends CharacterBody2D

enum CanonType {Mono, Double, Triple}
enum Type {Base}

signal arrived(tank)
signal dead(tank)
signal out_of_screen(tank)


@export var id : String
@export var speed = 300.0
@export var solidity : float = 5
@export var cooldown : float = .8
@export var canon_type : CanonType = CanonType.Mono
@export var type : Type = Type.Base
@export var projectile_speed : float = 4
@export var projectile_scene : PackedScene 
@export var initial_barrel_rotation : float = 0
@export var initial_body_rotation : float = 0

@onready var projectile_starting : Sprite2D = $"%Bullet"
@onready var lab_solidity : Label = $"%LabelSolidity"
@onready var body : Sprite2D = $"%Body"
@onready var barrel : Sprite2D = $"%Barrel"
@onready var explosion_sprites : AnimatedSprite2D = $"%Explosion"
@onready var _range : Area2D = $"%Range"
@onready var hit_area : CollisionShape2D = $"%CollisionShape"


var direction : Vector2
var shoot_timer = 0.5
var enemy : Tower = null
var target : Vector2
var roation_speed:float = 3
var peace_mode = false
var frozen = false

func _aim_at_enemy()->Vector2:
	if is_instance_valid(enemy):
		var tg = enemy.global_position
		var direction = (tg-barrel.global_position).normalized()
		var angle_to = barrel.transform.x.angle_to(direction) + deg_to_rad(initial_barrel_rotation)
		barrel.rotate(angle_to)
		return direction
	else:
		barrel.rotation = deg_to_rad(initial_barrel_rotation)
	return Vector2.ZERO

func _shoot(direction : Vector2)->void:
	AudioPlayer.play_sfx(AudioPlayer.SFX.TankShootNormal)
	var projectile : Projectile = projectile_scene.instantiate()
	projectile.speed = projectile_speed + 700
	projectile.direction = direction
	add_child(projectile)
	projectile.global_position = projectile_starting.global_position
	projectile.global_rotation = projectile_starting.global_rotation

func _physics_process(delta: float) -> void:
	if frozen:
		return
	if not peace_mode:
		# Look for towers
		enemy = null
		var rect = _range.get_child(0).shape.get_rect()
		rect.position += global_position
		for tower:Tower in get_tree().get_nodes_in_group("tower"):
			if rect.has_point(tower.hit_area.global_position):
				enemy = tower
				break
		
		var direction = _aim_at_enemy()
		
		# Handle shoots
		shoot_timer -= delta
		if shoot_timer <= 0 and is_instance_valid(enemy):
			shoot_timer = cooldown
			_shoot(direction)
		
	# Move toward path
	if global_position != target and target != Vector2(-1,-1):
		direction = (target - body.global_position).normalized()
		var angle_to = body.transform.x.angle_to(direction) + deg_to_rad(initial_body_rotation)
		body.rotate(signf(angle_to) * 1 * min(delta * roation_speed, abs(angle_to)) )
		
		var rect = hit_area.shape.get_rect()
		rect.position += global_position
		if rect.has_point(target):
			global_position = target
			arrived.emit(self)
	
		if direction.x:
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		if direction.y:
			velocity.y = direction.y * speed
		else:
			velocity.y = move_toward(velocity.y, 0, speed)
		
		position += velocity * delta
		
func explode()->void:
	AudioPlayer.play_sfx(AudioPlayer.SFX.TankNormalExplosion)
	body.hide()
	barrel.hide()
	lab_solidity.hide()
	explosion_sprites.show()
	explosion_sprites.play("default")

func take_damage(dmg:float)->void:
	solidity -= dmg
	lab_solidity.text = str(solidity)
	if solidity <= 0:
		dead.emit(self)
		explode()

func _on_animation_finished() -> void:
	queue_free()
	
