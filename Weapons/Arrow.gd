extends CharacterBody2D

var Damage = 25
var SPEED = 50000
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Automatically moves forward
func _physics_process(delta):
	velocity = (-transform.y * SPEED) * delta
	move_and_slide()




#damage ran into object and remove self.
func _on_area_2d_body_entered(body):
	if body.has_method("TakeDamage"):
		body.TakeDamage(Damage,GetKnockback())
	queue_free()

func GetKnockback():
	return null
