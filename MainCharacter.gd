extends CharacterBody2D

var SPEED = 400
var Weapon
var PSpear = "res://spear.tscn"
var PBow = "res://Bow.tscn"
var PSword = "res://Sword.tscn"
var PUI = preload("res://player_ui.tscn")
var UI
var MovingDirection : Vector2 = Vector2(0,0)
var Downed = false
var NearestInteractable = null
var Interactable = false
var InteractTime = 3
var InteractName = "Revive"
var HealthMax = 10000
var Health = 10000
#Network Usage Optimizations
var SyncPos = Vector2(0,0)
var SyncRot = 0

@export var AlliedSprite : Texture2D
@export var AlliedHandSprite : Texture2D
# Making $MultSync a variable helps with optimization
@onready var MultSync = $MultSync
@onready var state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
@onready var IdleMachine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/Idle/playback")
# Called when the node enters the scene tree for the first time.
func _ready():
	#Have to use $MultSync here to avoid errors
	$MultSync.set_multiplayer_authority(str(name).to_int())
	%Label.text = MultiplayerManager.Players[str(name).to_int()].Name
	if $MultSync.get_multiplayer_authority() == multiplayer.get_unique_id():
		$Camera2D.make_current()
		UI = PUI.instantiate()
		get_parent().add_child(UI)
		UI.SetHealth(Health,HealthMax)
	else:
		$Body.texture = AlliedSprite
		$Body/Hand1.texture = AlliedHandSprite
		$Body/Hand2.texture = AlliedHandSprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$LabelHolder.global_rotation = 0
	if (MultSync != null && LocalPlayer()
		&& Downed == false):
		if Input.is_action_just_pressed("LeftClick"):
			Attack.rpc()
		if Input.is_action_just_released("LeftClick"):
			ReleaseAttack.rpc()
		if Input.is_action_just_pressed("RightClick"):
			AltAttack.rpc()
		if Input.is_action_just_pressed("One"):
			GetSlotItem(0)
		if Input.is_action_just_pressed("Two"):
			GetSlotItem(1)
		if Input.is_action_just_pressed("Three"):
			GetSlotItem(2)
		if Input.is_action_just_pressed("Four"):
			GetSlotItem(3)
		if Input.is_action_just_pressed("Interact"):
			TryInteract()
		if Input.is_action_just_released("Interact"):
			TryStopInteract()
func _physics_process(delta):
	if (MultSync != null && LocalPlayer()
		&& Downed == false):
		velocity = Vector2()
		SyncPos = global_position
		SyncRot = global_rotation
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
	if LocalPlayer() == false:
		global_position = global_position.lerp(SyncPos,.5)
		global_rotation = SyncRot

func GetSlotItem(Index):
	var CurSlotItem = UI.GetSlotItem(Index)
	if CurSlotItem != null:
		ChangeWeapon.rpc(UI.GetSlotItem(Index).ItemToGive)
	else:
		ChangeWeapon.rpc(null)

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

func TryInteract():
	if NearestInteractable != null:
		UI.StartInteract(NearestInteractable.InteractTime)
		NearestInteractable.Interact.rpc()

func TryStopInteract():
	if NearestInteractable != null:
		UI.StopInteract()
		NearestInteractable.StopInteract.rpc()

func TakeDamage(Damage,Direction = null):
	Health = Health - Damage
	if Direction != null:
		MovingDirection = Direction
		var tween = create_tween()
		tween.tween_property(self,"MovingDirection",Vector2(0,0),.2)
	FlashDamage()
	if multiplayer.is_server():
		if Health <= 0:
			GoDown.rpc()
		if LocalPlayer():
			ServerSetHealth(Health)
		else:
			rpc_id(MultSync.get_multiplayer_authority(),"ServerSetHealth",Health)
		

@rpc("authority")
func ServerSetHealth(NewHealth):
	Health = NewHealth
	if LocalPlayer():
		UI.SetHealth(Health,HealthMax)

func Charge():
	MovingDirection = (transform.x * 1000)
	var tween = create_tween()
	tween.tween_property(self,"MovingDirection",Vector2(0,0),.4)

func BackStep():
	MovingDirection = (-transform.x * 1000)
	var tween = create_tween()
	tween.tween_property(self,"MovingDirection",Vector2(0,0),.2)

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
func AltAttack():
	if Weapon != null && Weapon.AltAttackAnim != "":
		state_machine.travel(Weapon.AltAttackAnim)

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

@rpc("authority","call_local")
func GoDown():
	modulate = Color(.5,.5,.5,1)
	Downed = true
	Interactable = true
	set_collision_layer_value(2,true)
	$InteractZone/CollisionShape2D.set_deferred("disabled", true)

@rpc("authority","call_local")
func Revived():
	Health = 25
	if LocalPlayer():
		UI.SetHealth(Health,HealthMax)
	Downed = false
	Interactable = false
	modulate = Color(1,1,1,1)
	set_collision_layer_value(2,false)
	$InteractZone/CollisionShape2D.set_deferred("disabled", false)

#On the player this is how we revive
@rpc("any_peer","call_local")
func Interact():
	$ReviveTimer.wait_time = InteractTime
	$ReviveTimer.start()
	if LocalPlayer():
		UI.ActionDoneTo("Being Revived", InteractTime)
@rpc("any_peer","call_local")
func StopInteract():
	$ReviveTimer.stop()
	if LocalPlayer():
		UI.ActionStopped()

func _on_revive_timer_timeout():
	if multiplayer.is_server():
		Revived.rpc()


func _on_interact_zone_body_entered(body):
	if body.has_method("Interact") && body.Interactable == true:
		NearestInteractable = body
		if LocalPlayer():
			UI.NewInteractable(NearestInteractable.InteractName)

func LocalPlayer():
	if MultSync.get_multiplayer_authority() == multiplayer.get_unique_id():
		return true
	else:
		return false

func _on_interact_zone_body_exited(body):
	if body == NearestInteractable:
		NearestInteractable.StopInteract.rpc()
		NearestInteractable = null
		if LocalPlayer():
			UI.LoseInteractable()
