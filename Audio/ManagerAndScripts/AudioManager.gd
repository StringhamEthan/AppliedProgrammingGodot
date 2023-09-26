extends Node

var PSoundPlayer = preload("res://Audio/ManagerAndScripts/SoundPlayer.tscn")

func PlaySoundAtLocation(Sound : String = "",NewPosition = Vector2(0,0)):
	if Sound != "":
		var SoundPlayer = PSoundPlayer.instantiate()
		get_tree().get_root().add_child(SoundPlayer)
		SoundPlayer.global_position = NewPosition
		SoundPlayer.Play(Sound)
