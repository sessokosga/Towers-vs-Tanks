class_name Tower extends Area2D

enum CanonType {Mono, Double}
enum UnlockConditions {None, ReachWave4, ReachWave7}
enum Type {Base,DoubleCanon, SingleMissile}
enum State {Alive,Dead}

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
@export var icon : Texture2D

@onready var body : Sprite2D = $"%Body"
@onready var base : Sprite2D = $"%Base"
@onready var hit_area : CollisionShape2D = $"%CollisionShape"
@onready var _range : Area2D = $"%Range"
@onready var projectile_starting : Sprite2D = $"%Projectile"
@onready var projectile_starting2 : Sprite2D 
@onready var explosion_sprites : AnimatedSprite2D = $Explosion
@onready var lab_solidity : Label = $"%LabelSolidity"


var shoot_timer = 0
var state = State.Alive
var peace_mode = false
var enemy : Tank = null
var cell : Vector2i
var frozen = false
var bonus_speed : float = 0

static var tower_nodes : Dictionary = {
	"tower249" : preload("res://towers/towers/tower_single_canon.tscn"),
	"tower250" : preload("res://towers/towers/tower_double_canon.tscn"),
	"tower206" : preload("res://towers/towers/tower_single_missile.tscn"),
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if canon_type == CanonType.Double:
		projectile_starting2 = $"%Projectile2"
	
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

func shoot(direction : Vector2,starting : Sprite2D = null)->void:
	AudioPlayer.play_sfx(AudioPlayer.SFX.TowerNormalShoot)
	
	var projectile : Projectile = projectile_scene.instantiate()
	projectile.speed = projectile_speed + 700 + bonus_speed * projectile_speed
	projectile.damage = damage
	projectile.direction = direction
	projectile.global_rotation = projectile_starting.global_rotation
	var pos = projectile.position
	if starting == null:
		starting = projectile_starting
	add_child(projectile)
	projectile.global_position = starting.global_position
	projectile_starting.hide()
	get_tree().create_timer(.1).timeout.connect(
		func ():
			projectile_starting.show()
			
	)
	

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
		shoot_timer -= delta + float(delta * bonus_speed)
		if shoot_timer <= 0 and is_instance_valid(enemy) and enemy.state == Tank.State.Alive:
			shoot_timer = cooldown
			shoot(direction)
			if canon_type == CanonType.Double:
				shoot(direction,projectile_starting2)
		
func explode()->void:
	AudioPlayer.play_sfx(AudioPlayer.SFX.TowerNormalExplosion)
	state = State.Dead
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
	if solidity <= 0 and state != State.Dead:
		dead.emit(self)
		explode()
		
static func get_instance(id:String)->Tower:
	return tower_nodes[id].instantiate()
	
static func get_string_type(tp:Type)->String:
	var type_str = ""
	match tp:
		Type.Base:
			type_str = "Single Canon"
		Type.DoubleCanon:
			type_str = "Double Canon"
		Type. SingleMissile:
			type_str = "Single Missile"
	return type_str
