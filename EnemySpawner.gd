extends Node2D

var PEnemy = preload("res://AI/BaseEnemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	if multiplayer.is_server():
		rpc("SpawnEnemies")

@rpc("authority","call_local")
func SpawnEnemies():
	var Enemy = PEnemy.instantiate()
	Enemy.global_position = global_position
	get_parent().add_child(Enemy)
