extends StaticBody2D
@export var Health : int = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func TakeDamage(damage,Direction = null):
	Health = Health - damage
	if Health <= 0:
		queue_free()
	else:
		$AnimationPlayer.play("Shake")
