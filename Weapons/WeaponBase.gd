extends Node2D

@export var Damage := 25
# The primary attack animation
@export var AttackAnim := ""
#the secondary attack animation
@export var AltAttackAnim := ""
#Animation to use during idle
@export var IdleAnim := ""
#Animation used if attack can be held
@export var ReleaseAnim := ""
#Sound to play
@export var AttackSound := ""

var HitEnemies = true
# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D/CollisionShape2D.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Enables the weapon to deal damage
func SetHitBox(NewSet : bool):
	$Area2D/CollisionShape2D.disabled = NewSet

#Damage whatever we came in contact with.
func _on_area_2d_body_entered(body):
	if body.has_method("TakeDamage") && body.is_in_group("Enemy") == HitEnemies:
		body.TakeDamage(Damage,GetKnockback())

#used to calculate knockback
func GetKnockback():
	return Vector2(cos(global_rotation-1.57), sin(global_rotation-1.57))*500
