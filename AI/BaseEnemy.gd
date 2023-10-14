extends CharacterBody2D

var Target
var Health = 100
var MovingDirection := Vector2(0,0)
var MoveSpeed = 200
var PunchRange = 150
var Weaving = false
var WeavingRange = 400
var WeaveLeft : bool = true
var Weapon = null
@onready var NavAgent : NavigationAgent2D = $NavigationAgent2D
@onready var state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
@onready var IdleMachine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/Idle/playback")
# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("Setup")

	

func Setup():
	ChangeWeapon("res://Weapons/spear.tscn")
	WeaveLeft = randi_range(0,1)
	WeavingRange = randf_range(300,600)
	MoveSpeed = randf_range(160,250)
	await get_tree().physics_frame
	Target = FindAlivePlayer()
	NavAgent.target_position = Target.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if Target == null:
		Target = FindAlivePlayer()
		return
	if MovingDirection != Vector2(0,0):
		velocity =  MovingDirection
		move_and_slide()
		return
	if Weaving == false:
		if NavAgent.is_navigation_finished():
			return
		velocity = NavAgent.get_next_path_position() - global_position
		velocity = velocity.normalized()
		velocity = velocity * MoveSpeed
		look_at(Target.global_position)
		move_and_slide()
		NavAgent.target_position = Target.global_position
		if global_position.distance_to(Target.global_position) < 100:
			Attack()
			Weaving = true
			$WeaveTimer.wait_time = randf_range(.3,.6)
			$WeaveTimer.start()
		if Target.Downed == true:
			Target = FindAlivePlayer()
	else:
		look_at(Target.global_position)
		print(global_position.distance_to(Target.global_position))
		if global_position.distance_to(Target.global_position) < WeavingRange:
			velocity = -transform.x * MoveSpeed
		elif global_position.distance_to(Target.global_position) > (WeavingRange + 100):
			velocity = transform.x * MoveSpeed
		else:
			if WeaveLeft == true:
				velocity = transform.y * MoveSpeed
			else:
				velocity = -transform.y * MoveSpeed
		#velocity *= transform.y
		move_and_slide()


func _on_area_2d_body_entered(body):
	print("HitSomething")
	if body.has_method("TakeDamage") && body.is_in_group("Enemy") == false:
		body.TakeDamage(25)


func FindAlivePlayer():
	for i in get_tree().get_nodes_in_group("Player"):
		if i.Downed == false:
			return i
	return null

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
			queue_free()

func FlashDamage():
	$Body/Hand1.material.set_shader_parameter("active",true)
	$Body/Hand2.material.set_shader_parameter("active",true)
	$Body.material.set_shader_parameter("active",true)
	await get_tree().create_timer(.1).timeout
	$Body.material.set_shader_parameter("active",false)
	$Body/Hand1.material.set_shader_parameter("active",false)
	$Body/Hand2.material.set_shader_parameter("active",false)


func EnableWeapon():
	if Weapon != null:
		Weapon.SetHitBox(false)

#make a weapon unable to do damage
func DisableWeapon():
	if Weapon != null:
		Weapon.SetHitBox(true)


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
		Weapon.HitEnemies = false
		IdleMachine.travel(Weapon.IdleAnim)
	else:
		IdleMachine.travel("PunchIdle")

#used by ranged weapons.
@rpc("any_peer","call_local")
func FireWeapon():
	if Weapon != null:
		Weapon.FireWeapon()


func PlayWeaponSound():
	if Weapon != null && Weapon.AttackSound != "":
		AudioManager.PlaySoundAtLocation(Weapon.AttackSound,global_position)



func _on_weave_timer_timeout():
	Weaving = false


func _on_change_direction_timer_timeout():
	$ChangeDirectionTimer.wait_time = randf_range(.4,.7)
	WeaveLeft = !WeaveLeft


