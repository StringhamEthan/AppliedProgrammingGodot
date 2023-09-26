extends CharacterBody2D

#Our Movement speed
var SPEED = 400
# what weapon we have equipped
var Weapon
# all the P<var>'s are to keep track of files in the filesystem for instantiation
var PUI = preload("res://UI/PlayerUI.tscn")
# The players UI
var UI
# This MovingDirection is used for things like charging or knockback
var MovingDirection : Vector2 = Vector2(0,0)
#If the player is in a "downed" state
var Downed = false
#What interactable they are currenlty looking at
var NearestInteractable = null
#Can they be interacted with? Used for reviving
var Interactable = false
#Amount of time it takes to interact
var InteractTime = 3
#The name for interactions
var InteractName = "Revive"
# Max Health
var HealthMax = 100
# Current Health
var Health = 100
#Network Usage Optimizations
var SyncPos = Vector2(0,0)
var SyncRot = 0

#Sprites for allies, used if this character is not controlled locally
@export var AlliedSprite : Texture2D
@export var AlliedHandSprite : Texture2D
# Making $MultSync a variable helps with optimization
@onready var MultSync = $MultSync
#The root state machine, used for animation
@onready var state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
#The idle machine, it is nested
@onready var IdleMachine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/Idle/playback")
# Called when the node enters the scene tree for the first time.
func _ready():
	#Have to use $MultSync here to avoid errors
	$MultSync.set_multiplayer_authority(str(name).to_int())
	%Label.text = MultiplayerManager.Players[str(name).to_int()].Name
	if $MultSync.get_multiplayer_authority() == multiplayer.get_unique_id():
		#setup local player
		$Camera2D.make_current()
		UI = PUI.instantiate()
		get_parent().add_child(UI)
		#call deferred to avoid just instantiated issues
		UI.call_deferred("SetHealth",Health,HealthMax)
	else:
		#Not local, therefore make an ally
		$Body.texture = AlliedSprite
		$Body/Hand1.texture = AlliedHandSprite
		$Body/Hand2.texture = AlliedHandSprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$LabelHolder.global_rotation = 0
	#Make sure only the local player is doing inputs.
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
	#Make sure only the local player is doing inputs
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
	#If not local player, lerp values for others.
	if LocalPlayer() == false:
		global_position = global_position.lerp(SyncPos,.5)
		global_rotation = SyncRot

#We are changing the item, so grab it from the UI, which manages that.
func GetSlotItem(Index):
	var CurSlotItem = UI.GetSlotItem(Index)
	if CurSlotItem != null:
		ChangeWeapon.rpc(UI.GetSlotItem(Index).ItemToGive)
	else:
		ChangeWeapon.rpc(null)

#Used when punching
func _on_area_2d_body_entered(body):
	if body.has_method("TakeDamage"):
		body.TakeDamage(25)

#Make a weapon able to do damage
func EnableWeapon():
	if Weapon != null:
		Weapon.SetHitBox(false)

#make a weapon unable to do damage
func DisableWeapon():
	if Weapon != null:
		Weapon.SetHitBox(true)

#loads a weapon, like giving the bow an arrow
func LoadWeapon():
	if Weapon != null:
		Weapon.LoadWeapon()

#Unload the weapon, setting it back to default
func UnloadWeapon():
	if Weapon != null:
		Weapon.UnloadWeapon()

#Attempt to interact with something.
func TryInteract():
	if NearestInteractable != null:
		UI.StartInteract(NearestInteractable.InteractTime)
		NearestInteractable.Interact.rpc()

#Stop interacting with something
func TryStopInteract():
	if NearestInteractable != null:
		UI.StopInteract()
		NearestInteractable.StopInteract.rpc()

#Handle damage.
func TakeDamage(Damage,Direction = null):
	Health = Health - Damage
	if Direction != null:
		MovingDirection = Direction
		var tween = create_tween()
		tween.tween_property(self,"MovingDirection",Vector2(0,0),.2)
	FlashDamage()
	#Only the server can decide if someone dies
	if multiplayer.is_server():
		if Health <= 0:
			GoDown.rpc()
		if LocalPlayer():
			ServerSetHealth(Health)
		else:
			rpc_id(MultSync.get_multiplayer_authority(),"ServerSetHealth",Health)
		

# Multiplayer set health to keep in sync
@rpc("authority")
func ServerSetHealth(NewHealth):
	Health = NewHealth
	if LocalPlayer():
		UI.SetHealth(Health,HealthMax)

#Launches the player foward. Called via animation
func Charge():
	MovingDirection = (transform.x * 1000)
	var tween = create_tween()
	tween.tween_property(self,"MovingDirection",Vector2(0,0),.4)

#Launches the player backwards, called via animation
func BackStep():
	MovingDirection = (-transform.x * 1000)
	var tween = create_tween()
	tween.tween_property(self,"MovingDirection",Vector2(0,0),.2)

#Uses a simple shader to flash the sprites. Called when damaged.
func FlashDamage():
	$Body/Hand1.material.set_shader_parameter("active",true)
	$Body/Hand2.material.set_shader_parameter("active",true)
	$Body.material.set_shader_parameter("active",true)
	await get_tree().create_timer(.1).timeout
	$Body.material.set_shader_parameter("active",false)
	$Body/Hand1.material.set_shader_parameter("active",false)
	$Body/Hand2.material.set_shader_parameter("active",false)

#A replicated function that plays the attack animations
@rpc("any_peer","call_local")
func Attack():
	if Weapon == null:
		state_machine.travel("Punch")
	else:
		state_machine.travel(Weapon.AttackAnim)

#Same as above but for alternate attacks.
@rpc("any_peer","call_local")
func AltAttack():
	if Weapon != null && Weapon.AltAttackAnim != "":
		state_machine.travel(Weapon.AltAttackAnim)

#Some attacks can be held, this releases them.
@rpc("any_peer","call_local")
func ReleaseAttack():
	if Weapon != null && Weapon.ReleaseAnim != "":
		state_machine.travel(Weapon.ReleaseAnim)

#Changes the weapon and sets idle to the correct idle anim.
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

#used by ranged weapons.
@rpc("any_peer","call_local")
func FireWeapon():
	if Weapon != null:
		Weapon.FireWeapon()

#puts the playerin the downed state and must be revived
@rpc("authority","call_local")
func GoDown():
	modulate = Color(.5,.5,.5,1)
	Downed = true
	Interactable = true
	#set scene to the collision layer interactables check
	set_collision_layer_value(2,true)
	$InteractZone/CollisionShape2D.set_deferred("disabled", true)

#Called when revived by another.
@rpc("authority","call_local")
func Revived():
	Health = 25
	if LocalPlayer():
		UI.SetHealth(Health,HealthMax)
	Downed = false
	Interactable = false
	modulate = Color(1,1,1,1)
	#Disable collision with interactable scanners
	set_collision_layer_value(2,false)
	$InteractZone/CollisionShape2D.set_deferred("disabled", false)

#On the player this is how we revive
@rpc("any_peer","call_local")
func Interact():
	$ReviveTimer.wait_time = InteractTime
	$ReviveTimer.start()
	if LocalPlayer():
		UI.ActionDoneTo("Being Revived", InteractTime)
#In case the other player is interrupted
@rpc("any_peer","call_local")
func StopInteract():
	$ReviveTimer.stop()
	if LocalPlayer():
		UI.ActionStopped()

func PlayWeaponSound():
	if Weapon != null && Weapon.AttackSound != "":
		AudioManager.PlaySoundAtLocation(Weapon.AttackSound,global_position)
		

#If this succeeds the player is revived
func _on_revive_timer_timeout():
	if multiplayer.is_server():
		Revived.rpc()

#Checking to set current nearest interactables
func _on_interact_zone_body_entered(body):
	if body.has_method("Interact") && body.Interactable == true:
		NearestInteractable = body
		if LocalPlayer():
			UI.NewInteractable(NearestInteractable.InteractName)

#Check if this scene is controlled by a local player
func LocalPlayer():
	if MultSync.get_multiplayer_authority() == multiplayer.get_unique_id():
		return true
	else:
		return false

#If body is NearestInteractable, remove it.
func _on_interact_zone_body_exited(body):
	if body == NearestInteractable:
		NearestInteractable.StopInteract.rpc()
		NearestInteractable = null
		if LocalPlayer():
			UI.LoseInteractable()
