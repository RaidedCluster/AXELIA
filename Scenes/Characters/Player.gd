extends KinematicBody2D

const ACCELERATION = 1000
const MAX_SPEED = 250
const RUN_SPEED_MULTIPLIER = 2  # Adjust the multiplier as needed
const FRICTION = 7000
signal interacted(body)

const STAMINA_MAX = 100
const STAMINA_DRAIN = 30  # The amount of stamina drained per second while running.
const STAMINA_REGEN = 10  # The amount of stamina regenerated per second when not running.

var current_stamina = STAMINA_MAX
var unlimited_stamina = false

enum {
	MOVE
}

var state = MOVE
var velocity = Vector2.ZERO
var watchson_active = false

onready var interactionArea = $"Interaction Pivot/Interaction Area"
onready var animationPlayer = $AnimationPlayer
onready var currentAnimation = animationPlayer.current_animation
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
	regenerate_stamina(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	var is_running = Input.is_action_pressed("ui_run") and current_stamina > 0
	var current_acceleration = ACCELERATION

	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Walk/blend_position", input_vector)

		if is_running:
			if not unlimited_stamina:
				current_stamina -= STAMINA_DRAIN * delta  # Only drain stamina if not in unlimited stamina mode
			animationTree.set("parameters/Run/blend_position", input_vector)
			animationState.travel("Run")
			current_acceleration *= RUN_SPEED_MULTIPLIER
			velocity = velocity.move_toward(input_vector * MAX_SPEED * RUN_SPEED_MULTIPLIER, current_acceleration * delta)
		else:
			animationState.travel("Walk")
			velocity = velocity.move_toward(input_vector * MAX_SPEED, current_acceleration * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Clamp the stamina to ensure it doesn't go below 0 or above the max.
	current_stamina = clamp(current_stamina, 0, STAMINA_MAX)

	# Update the stamina bar by finding it from the root node.
	var stamina_bar = get_tree().root.find_node("StaminaBar", true, false)
	if stamina_bar:
		stamina_bar.update_stamina(current_stamina)

	move()

func move():
	velocity = move_and_slide(velocity)

func _on_Interaction_Area_body_entered(body):
	emit_signal("interacted", body)

func set_watchson_active(is_active):
	watchson_active = is_active

func regenerate_stamina(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	var is_running = Input.is_action_pressed("ui_run") and input_vector != Vector2.ZERO

	if not is_running and current_stamina < STAMINA_MAX:
		current_stamina += STAMINA_REGEN * delta
		current_stamina = min(current_stamina, STAMINA_MAX)  # Ensure it doesn't exceed max.

	# Find the StaminaBar from the root node of the scene tree
	var stamina_bar = get_tree().root.find_node("StaminaBar", true, false)
	if stamina_bar:
		stamina_bar.update_stamina(current_stamina)
	else:
		print("StaminaBar node not found in the scene tree.")

func update_stamina_bar():
	var stamina_bar = get_tree().root.find_node("StaminaBar", true, false)
	if stamina_bar:
		stamina_bar.update_stamina(current_stamina)
	else:
		print("StaminaBar node not found in the scene tree.")

func _ready():
	# Attempt to find the Inventory node and connect the signal
	var inventory = get_tree().root.find_node("Inventory", true, false)
	if inventory:
		inventory.connect("recharge_drink_consumed", self, "_on_recharge_drink_consumed")

func _on_recharge_drink_consumed():
	current_stamina = STAMINA_MAX  # Set current stamina to maximum
	activate_unlimited_stamina(30)  # For example, 30 seconds duration

func activate_unlimited_stamina(duration):
	unlimited_stamina = true
	update_stamina_bar_unlimited_status(true)  # Update StaminaBar status
	yield(get_tree().create_timer(duration), "timeout")
	unlimited_stamina = false
	update_stamina_bar_unlimited_status(false)  # Update StaminaBar status

func update_stamina_bar_unlimited_status(status: bool):
	var stamina_bar = get_tree().root.find_node("StaminaBar", true, false)
	if stamina_bar:
		stamina_bar.set_unlimited_stamina_status(status)
