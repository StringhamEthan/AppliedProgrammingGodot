extends Node2D

@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	#Spawn all the playres in a multiplayer friendly way
	for i in MultiplayerManager.Players:
		var CurrentPlayer = PlayerScene.instantiate()
		CurrentPlayer.name = str(MultiplayerManager.Players[i].id)
		add_child(CurrentPlayer)
		var Spawn = get_tree().get_first_node_in_group("Spawner")
		if Spawn != null:
			randomize()
			CurrentPlayer.global_position = (Spawn.global_position + Vector2(randi_range(-300,300),randi_range(-300,300)))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
