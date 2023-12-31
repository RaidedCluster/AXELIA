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

var can_interact = true

onready var sight_area = $SightArea
# Flag to ensure dialogue only plays once
var has_seen_bot = false

enum {
	MOVE
}

var state = MOVE
var velocity = Vector2.ZERO
var watchson_active = false
var watchson_ui_active = false

onready var interactionArea = $"Interaction Pivot/Interaction Area"
onready var animationPlayer = $AnimationPlayer
onready var currentAnimation = animationPlayer.current_animation
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

# Player.gd
func _physics_process(delta):
	if can_interact:
		match state:
			MOVE:
				move_state(delta)
		regenerate_stamina(delta)
	# Do not process movement or stamina regeneration if can_interact is false


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
	if body.name in ["GuardrailLeft","GuardrailRight"]:  # Replace with your guardrail's identifying property
		disable_interaction()  # Disable player movement and interaction
		var inventory = get_tree().get_root().find_node("Inventory", true, false)
		if inventory:
			inventory.disable_inventory_interaction()
		play_guardrail_warning_dialogue()  # Start the guardrail warning dialogue
	else:
		emit_signal("interacted", body)

func play_guardrail_warning_dialogue():
	var dialogue = Dialogic.start("TutorialWarn")
	dialogue.pause_mode = Node.PAUSE_MODE_PROCESS
	get_parent().add_child(dialogue)  # You might need to adjust the path to where you want to add the dialogue
	yield(dialogue, "tree_exited")  # Wait for the dialogue to finish
	enable_interaction()  # Re-enable player movement and interaction
	var inventory = get_tree().get_root().find_node("Inventory", true, false)
	if inventory:
		inventory.enable_inventory_interaction()

func set_watchson_active(is_active):
	watchson_active = is_active

func set_watchson_ui_active(is_active):
	watchson_ui_active = is_active

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
	sight_area.connect("body_entered", self, "_on_SightArea_body_entered")
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

func disable_interaction():
	can_interact = false
	print("Player interaction disabled")

func enable_interaction():
	can_interact = true
	print("Player interaction enabled")

func _on_SightArea_body_entered(body):
	if body.name == "Kinesys Sentinel" and not has_seen_bot:
		# Play the dialogue using Dialogic
		var dialogue = Dialogic.start('Kinesys')
		dialogue.pause_mode = Node.PAUSE_MODE_PROCESS
		add_child(dialogue)
		has_seen_bot = true  # Set the flag so it doesn't play again
		# You may want to disable player movement while dialogue is playing
		var inventory = get_tree().get_root().find_node("Inventory", true, false)
		if inventory:
			inventory.disable_inventory_interaction()
		yield(dialogue, "tree_exited")  # Wait for the dialogue to finish
		# Re-enable player movement after dialogue
		if inventory:
			inventory.enable_inventory_interaction()

func show_bot_approach_dialogue():
	if not has_seen_bot:
		var dialogue = Dialogic.start('Approach')  # Replace 'BotApproach' with your actual dialogue event
		dialogue.pause_mode = Node.PAUSE_MODE_PROCESS
		add_child(dialogue)
		yield(dialogue, "tree_exited")
