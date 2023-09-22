extends Node2D

@export var Damage := 25
@export var AttackAnim := ""
@export var IdleAnim := ""
@export var ReleaseAnim := ""
@export var PProjectile = "res://arrow.tscn"
@export var LoadedBow : Texture2D
@export var UnloadedBow : Texture2D
func SpawnProjectile():
	var Proj = load(PProjectile).instantiate()
	get_tree().get_first_node_in_group("LevelManager").add_child(Proj)
	Proj.global_position = global_position
	Proj.global_rotation = global_rotation

func LoadWeapon():
	$BowSprite.texture = LoadedBow

func UnloadWeapon():
	$BowSprite.texture = UnloadedBow

func FireWeapon():
	SpawnProjectile()
