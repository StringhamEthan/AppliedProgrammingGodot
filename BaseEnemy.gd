extends CharacterBody2D

var Target
var MoveSpeed = 200
@onready var NavAgent : NavigationAgent2D = $NavigationAgent2D
@onready var state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("Setup")

	

func Setup():
	await get_tree().physics_frame
	Target = get_tree().get_first_node_in_group("Player")
	NavAgent.target_position = Target.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if NavAgent.is_navigation_finished():
		return
	velocity = NavAgent.get_next_path_position() - global_position
	velocity = velocity.normalized()
	velocity = velocity * MoveSpeed
	look_at(Target.global_position)
	move_and_slide()
	NavAgent.target_position = Target.global_position
	if global_position.distance_to(Target.global_position) < 100:
		state_machine.travel("Punch")


func _on_area_2d_body_entered(body):
	print("HitSomething")
	if body.has_method("TakeDamage"):
		body.TakeDamage(25)
