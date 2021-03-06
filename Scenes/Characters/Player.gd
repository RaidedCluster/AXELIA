extends KinematicBody2D

const ACCELERATION = 1000
const MAX_SPEED = 250
const FRICTION = 7000

enum {
	MOVE
}

var state = MOVE
var velocity = Vector2.ZERO

onready var animationPlayer=$AnimationPlayer
onready var animationTree=$AnimationTree
onready var animationState=animationTree.get("parameters/playback")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position",input_vector)
		animationTree.set("parameters/Walk/blend_position",input_vector)
		animationState.travel("Walk")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()

func move():
	velocity = move_and_slide(velocity)

