extends Node2D

@export var Damage = 25
@export var KnockBack = 100
var ContainedBodies = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	#make em take damage and add them to the list of things to keep hurting
	if body.has_method("TakeDamage"):
		body.TakeDamage(Damage,GetKnockback())
		ContainedBodies.append(body)


func _on_timer_timeout():
	#in case they are still in the range of the spearpoint
	for i in ContainedBodies:
		i.TakeDamage(Damage,GetKnockback())


func _on_area_2d_body_exited(body):
	#If the player leaves, we don't want to hurt them anymore
	if ContainedBodies.has(body):
		ContainedBodies.erase(body)

func GetKnockback():
	return Vector2(cos(global_rotation-1.57), sin(global_rotation-1.57))*500
