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
	randomize()
	var cameras = get_tree().get_nodes_in_group("cameras")
	setup_cameras(cameras)
	setup_maintenance_timer()

	var player = get_tree().get_root().find_node("Player", true, false)
	var inventory = get_tree().get_root().find_node("Inventory", true, false)

	if Global.is_first_playthrough:
		start_tutorial(player, inventory)
	else:
		setup_for_retry(player, inventory)

func setup_cameras(cameras):
	for camera in cameras:
		var error = camera.connect("disabled", self, "_on_Camera_disabled")
		if error == OK:
			print("Successfully connected disabled signal for camera: ", camera.name)
		else:
			print("Failed to connect disabled signal for camera: ", camera.name, " Error: ", error)
		camera.connect("caught", self, "_on_Camera_Caught")

func setup_maintenance_timer():
	maintenance_timer.set_wait_time(60.0)  # Set for 60 seconds
	maintenance_timer.set_one_shot(true)
	maintenance_timer.connect("timeout", self, "_on_MaintenanceTimer_timeout")
	add_child(maintenance_timer)

func start_tutorial(player, inventory):
	if player:
		player.disable_interaction()
	if inventory:
		inventory.disable_inventory_interaction()

	var tutorial_dialog = Dialogic.start('Tutorial')
	tutorial_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(tutorial_dialog)
	yield(tutorial_dialog, "tree_exited") 
	_on_TutorialDialogue_end()

func setup_for_retry(player, inventory):
	# Set game state as it should be after the tutorial ends
	if player:
		player.enable_interaction()  # Or set the player's state as required
	if inventory:
		inventory.enable_inventory_interaction()  # Or set the inventory's state as required
	# Additional setup as required for the game state post-tutorial

func _on_Camera_disabled(camera_name):
	print("Camera disabled signal received for: ", camera_name)
	disabled_cameras[camera_name] = true
	if all_cameras_disabled():
		print("All cameras have been disabled at least once.")

func all_cameras_disabled():
	var cameras = get_tree().get_nodes_in_group("cameras")
	for camera in cameras:
		if not disabled_cameras.get(camera.name, false):
			return false
	start_maintenance_mode()
	return true

func start_maintenance_mode():
	var cameras = get_tree().get_nodes_in_group("cameras")
	for camera in cameras:
		camera.enter_maintenance_mode()
	maintenance_timer.start()

func _on_MaintenanceTimer_timeout():
	var cameras = get_tree().get_nodes_in_group("cameras")
	for camera in cameras:
		camera.exit_maintenance_mode()
	reset_disabled_cameras()

func reset_disabled_cameras():
	disabled_cameras.clear()

func _on_Camera_Caught():
	player_caught = true
	emit_signal("player_caught_changed", player_caught)
	if alarmSound and not alarmSound.playing:
		alarmSound.play()

func _on_TutorialDialogue_end():
	var ui_controls = get_node("UI/Tutorial/Controls")
	var ui_texture_rect = get_node("UI/TextureRect")
	
	ui_controls.visible = true
	ui_texture_rect.visible = true

	yield(get_tree().create_timer(2.0), "timeout")

	ui_controls.visible = false
	ui_texture_rect.visible = false

	var tutorial_dialog_2 = Dialogic.start('Tutorial2')
	tutorial_dialog_2.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(tutorial_dialog_2)
	yield(tutorial_dialog_2, "tree_exited")
	_on_Tutorial2Dialogue_end()

func _on_Tutorial2Dialogue_end():
	var inventory = get_tree().get_root().find_node("Inventory", true, false)
	if inventory:
		inventory.enable_inventory_interaction()

	# Make the arrow visible
	var arrow = get_node("UI/Tutorial/Arrow-to-Watchson")
	arrow.visible = true
	var arrow_animation_player = get_node("UI/Tutorial/Arrow-to-Watchson/AnimationPlayer")
	arrow_animation_player.play("ArrowAnimation")
	# Create a timer to hide the arrow after 3 seconds
	var arrow_timer = Timer.new()
	arrow_timer.set_wait_time(3.0)  # 3 seconds
	arrow_timer.set_one_shot(true)
	arrow_timer.connect("timeout", self, "_on_ArrowTimer_timeout", [arrow])
	add_child(arrow_timer)
	arrow_timer.start()

func _on_ArrowTimer_timeout(arrow: Node):
	var arrow_animation_player = arrow.get_node("AnimationPlayer")
	arrow_animation_player.stop()
	arrow.visible = false
	arrow.queue_free()  # Optionally, remove the arrow node if it's no longer needed

func get_maintenance_time_left():
	if maintenance_timer.is_stopped():
		return 0
	else:
		return maintenance_timer.time_left
