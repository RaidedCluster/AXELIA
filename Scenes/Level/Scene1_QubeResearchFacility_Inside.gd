extends Node2D

# Dictionary to keep track of cameras
var disabled_cameras = {}
var maintenance_timer = Timer.new()
var player_caught = false
onready var alarmSound = $AlarmSound

var arrow_shown = false
var bot_instanced = false

signal player_caught_changed(is_caught)

func _ready():
	print(get_tree().get_root().get_path_to(self))
	var cameras = get_tree().get_nodes_in_group("cameras")

	for camera in cameras:
		# Connect the 'disabled' signal as before
		var error = camera.connect("disabled", self, "_on_Camera_disabled")
		if error == OK:
			print("Successfully connected disabled signal for camera: ", camera.name)
		else:
			print("Failed to connect disabled signal for camera: ", camera.name, " Error: ", error)

		# Connect the 'caught' signal to a new function
		camera.connect("caught", self, "_on_Camera_Caught")

	maintenance_timer.set_wait_time(60.0)  # Set for 60 seconds
	maintenance_timer.set_one_shot(true)
	maintenance_timer.connect("timeout", self, "_on_MaintenanceTimer_timeout")
	add_child(maintenance_timer)
	var player = get_tree().get_root().find_node("Player", true, false)
	var inventory = get_tree().get_root().find_node("Inventory", true, false)

	if player:
		player.disable_interaction()
	if inventory:
		inventory.disable_inventory_interaction()

	# Start the "Tutorial" dialogue and wait for it to finish
	var tutorial_dialog = Dialogic.start('Tutorial')
	tutorial_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(tutorial_dialog)

	# Assuming Dialogic dialogues are CanvasItem; adjust as necessary
	yield(tutorial_dialog, "tree_exited") # Wait for the dialogue node to be removed from the tree

	# Re-enable interactions after the dialogue ends
	_on_TutorialDialogue_end()

func _on_Camera_disabled(camera_name):
	print("Camera disabled signal received for: ", camera_name)
	disabled_cameras[camera_name] = true

	# Debug print to show current state of disabled cameras
	print("Current disabled cameras: ", disabled_cameras)

	if all_cameras_disabled():
		print("All cameras have been disabled at least once.")


func all_cameras_disabled():
	var cameras = get_tree().get_nodes_in_group("cameras")
	for camera in cameras:
		if not disabled_cameras.get(camera.name, false):
			return false
	# Start maintenance mode
	start_maintenance_mode()
	return true

func start_maintenance_mode():
	# Trigger maintenance mode for each camera
	var cameras = get_tree().get_nodes_in_group("cameras")
	for camera in cameras:
		camera.enter_maintenance_mode()
	# Start the centralized maintenance timer
	maintenance_timer.start()

func _on_MaintenanceTimer_timeout():
	# End maintenance mode
	var cameras = get_tree().get_nodes_in_group("cameras")
	for camera in cameras:
		camera.exit_maintenance_mode()
	reset_disabled_cameras()  # Reset the state of disabled cameras

func get_maintenance_time_left():
	return maintenance_timer.time_left

func reset_disabled_cameras():
	disabled_cameras.clear()

func _on_Camera_Caught():
	player_caught = true
	emit_signal("player_caught_changed", player_caught)
	# Play the alarm sound
	if alarmSound and not alarmSound.playing:
		alarmSound.play()

#TUTORIAL.
func _on_TutorialDialogue_end():
	# Display the controls overlay
	
	var ui_controls = get_node("UI/Tutorial/Controls")
	var ui_texture_rect = get_node("UI/TextureRect")
	
	ui_controls.visible = true
	ui_texture_rect.visible = true
	
	# Wait for 2 seconds before hiding the controls overlay and enabling interactions
	yield(get_tree().create_timer(2.0), "timeout")

	ui_controls.visible = false
	ui_texture_rect.visible = false

	# Start the second tutorial dialogue "Tutorial2"
	var tutorial_dialog_2 = Dialogic.start('Tutorial2')
	tutorial_dialog_2.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(tutorial_dialog_2)

	# Wait for the "Tutorial2" dialogue to complete before taking further action
	yield(tutorial_dialog_2, "tree_exited") # Assuming the dialogue is removed from the scene tree when finished
	
	_on_Tutorial2Dialogue_end()

func _on_Tutorial2Dialogue_end():
		var inventory = get_tree().get_root().find_node("Inventory", true, false)
		if inventory:
			inventory.enable_inventory_interaction()
