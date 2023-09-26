extends Node2D

@export var Damage := 25
@export var AttackAnim := ""
@export var AltAttackAnim := ""
@export var IdleAnim := ""
@export var ReleaseAnim := ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D/CollisionShape2D.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func SetHitBox(NewSet : bool):
	$Area2D/CollisionShape2D.disabled = NewSet


func _on_area_2d_body_entered(body):
	if body.has_method("TakeDamage"):
		body.TakeDamage(Damage,GetKnockback())

func GetKnockback():
	return Vector2(cos(global_rotation-1.57), sin(global_rotation-1.57))*500
