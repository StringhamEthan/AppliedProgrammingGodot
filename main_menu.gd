extends Control
var RandomNames = ["Bob","Joe","Phillip","Carl","Donny"]
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$NameLine.text = RandomNames.pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_button_pressed():
	MultiplayerManager.BeginHosting($NameLine.text)


func _on_join_button_pressed():
	MultiplayerManager.JoinGame($NameLine.text)


func _on_start_game_pressed():
	StartGame.rpc()

@rpc("any_peer","call_local") 
func StartGame():
	TransitionManager.Transition()
	await get_tree().create_timer(.5).timeout
	get_tree().change_scene_to_file("res://MainMap.tscn")
