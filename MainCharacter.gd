extends CharacterBody2D

var SPEED = 400
var Weapon
var PSpear = "res://spear.tscn"
var PBow = "res://Bow.tscn"
var MovingDirection : Vector2 = Vector2(0,0)
@export var AlliedSprite : Texture2D
@export var AlliedHandSprite : Texture2D
@onready var MultSync = $MultSync
@onready var state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
@onready var IdleMachine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/Idle/playback")
# Called when the node enters the scene tree for the first time.
func _ready():
	$MultSync.set_multiplayer_authority(str(name).to_int())
	%Label.text = MultiplayerManager.Players[str(name).to_int()].Name
	if $MultSync.get_multiplayer_authority() == multiplayer.get_unique_id():
		$Camera2D.make_current()
	else:
		$Body.texture = AlliedSprite
		$Body/Hand1.texture = AlliedHandSprite
		$Body/Hand2.texture = AlliedHandSprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$LabelHolder.global_rotation = 0
	if MultSync != null && MultSync.get_multiplayer_authority() == multiplayer.get_unique_id():
		if Input.is_action_just_pressed("LeftClick"):
			Attack.rpc()
		if Input.is_action_just_released("LeftClick"):
			ReleaseAttack.rpc()
		if Input.is_action_just_pressed("One"):
			ChangeWeapon.rpc(null)
		if Input.is_action_just_pressed("Two"):
			ChangeWeapon.rpc(PSpear)
		if Input.is_action_just_pressed("Three"):
			ChangeWeapon.rpc(PBow)
func _physics_process(delta):
	if MultSync != null && MultSync.get_multiplayer_authority() == multiplayer.get_unique_id():
		velocity = Vector2()
		#Don't allow the player to move while they are being knocked back
		if MovingDirection == Vector2(0,0):
			if Input.is_action_pressed("Right"):
				velocity.x += 1;
			if Input.is_action_pressed("Left"):
				velocity.x -= 1;
			if Input.is_action_pressed("Down"):
				velocity.y += 1;
			if Input.is_action_pressed("Up"):
				velocity.y -= 1;
		velocity = velocity.normalized() * SPEED
		velocity = velocity + MovingDirection
		look_at(get_global_mouse_position())
		move_and_slide()



func _on_area_2d_body_entered(body):
	if body.has_method("TakeDamage"):
		body.TakeDamage(25)

func EnableWeapon():
	if Weapon != null:
		Weapon.SetHitBox(false)
func DisableWeapon():
	if Weapon != null:
		Weapon.SetHitBox(true)

func LoadWeapon():
	if Weapon != null:
		Weapon.LoadWeapon()

func UnloadWeapon():
	if Weapon != null:
		Weapon.UnloadWeapon()

func TakeDamage(Damage,Direction = null):
	if Direction != null:
		MovingDirection = Direction
		var tween = create_tween()
		tween.tween_property(self,"MovingDirection",Vector2(0,0),.2)
	FlashDamage()

func FlashDamage():
	$Body/Hand1.material.set_shader_parameter("active",true)
	$Body/Hand2.material.set_shader_parameter("active",true)
	$Body.material.set_shader_parameter("active",true)
	await get_tree().create_timer(.1).timeout
	$Body.material.set_shader_parameter("active",false)
	$Body/Hand1.material.set_shader_parameter("active",false)
	$Body/Hand2.material.set_shader_parameter("active",false)

@rpc("any_peer","call_local")
func Attack():
	if Weapon == null:
		state_machine.travel("Punch")
	else:
		state_machine.travel(Weapon.AttackAnim)

@rpc("any_peer","call_local")
func ReleaseAttack():
	if Weapon != null && Weapon.ReleaseAnim != "":
		state_machine.travel(Weapon.ReleaseAnim)

@rpc("any_peer","call_local")
func ChangeWeapon(NewWeapon):
	if Weapon != null:
		Weapon.queue_free()
	Weapon = null
	if NewWeapon != null:
		Weapon = load(NewWeapon).instantiate()
		$Body/Hand1.add_child(Weapon)
		Weapon.global_position = $Body/Hand1.global_position
		IdleMachine.travel(Weapon.IdleAnim)
	else:
		IdleMachine.travel("PunchIdle")

@rpc("any_peer","call_local")
func FireWeapon():
	if Weapon != null:
		Weapon.FireWeapon()
