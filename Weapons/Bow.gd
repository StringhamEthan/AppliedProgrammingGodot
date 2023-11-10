extends Node2D

#This class is designed to be as similar to Weaponbase as possible
#With only differences in places needed.


@export var Damage := 25
@export var AttackAnim := ""
@export var AltAttackAnim := ""
@export var IdleAnim := ""
@export var ReleaseAnim := ""
@export var PProjectile = "res://Weapons/arrow.tscn"
@export var AttackSound := ""
#Sprite to swap in when loaded
@export var LoadedBow : Texture2D
#Sprite to swap in when unloaded
@export var UnloadedBow : Texture2D

var HitEnemies = true
#creates the projectile and sends it on its way.
func SpawnProjectile():
	var Proj = load(PProjectile).instantiate()
	get_tree().get_first_node_in_group("LevelManager").add_child(Proj)
	Proj.HitEnemies = HitEnemies
	Proj.global_position = global_position
	Proj.global_rotation = global_rotation

#swap texture
func LoadWeapon():
	$BowSprite.texture = LoadedBow
#reverse above
func UnloadWeapon():
	$BowSprite.texture = UnloadedBow
#This function doesn't do a lot for now, but might in the future.
func FireWeapon():
	SpawnProjectile()
