extends Control

var camera_node = null
var showWarning = false  # New variable to control the warning display

# Dictionary to keep track of active timers for each camera
var flash_timers = {}

# Initialize the script with the camera node
func init(camera):
	camera_node = camera
	$OnOff.connect("pressed", self, "_on_OnOff_pressed")
	$ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	$FeedSettings.connect("pressed", self, "_on_FeedSettings_pressed")
	$Network.connect("pressed", self, "_on_Network_pressed")  # Connect the Network button pressed signal
	camera_node.connect("stream_replay_failed", self, "_on_StreamReplay_failed")
	camera_node.connect("maintenance_mode_changed", self, "update_ui")

	# Update the UI based on the current state of the camera node
	update_ui()

func update_ui():
	if not is_inside_tree():
		return

	var main_controller = get_tree().get_root().find_node("QRF", true, false)
	if not main_controller:
		print("Main controller (QRF) not found.")
		return

	# Fetch the maintenance time left from the main controller
	var maintenance_time_left = 0
	if main_controller.has_method("get_maintenance_time_left"):
		maintenance_time_left = main_controller.call("get_maintenance_time_left")
	else:
		print("Method 'get_maintenance_time_left' not found in QRF.")
		return

	# Assuming maintenance takes precedence over other states, we check it first.
	if camera_node.isInMaintenance:
		# Ensure only maintenance section is visible
		$MaintenanceToggleSection.visible = true
		$OnOffToggleSection.visible = false
		$FeedSettingsToggleSection.visible = false
		$NetworkToggleSection.visible = false
		$OnOff.visible = false
		$FeedSettings.visible = false
		$Network.visible = false
		$MaintenanceToggleSection/CountdownLabel.bbcode_text = "[center]" + str(int(maintenance_time_left)) + "[/center]"
	elif camera_node.isDisabled:
		# Update UI for disabled state
		var time_left = int(round(camera_node.get_time_left()))
		
		if camera_node.is_stream_replayed:
			# Show FeedSettingsToggleSection for stream replay
			$FeedSettingsToggleSection.visible = true
			$FeedSettingsToggleSection/CountdownLabel.bbcode_text = "[center]" + str(int(time_left)) + "[/center]"
			$OnOffToggleSection.visible = false
		else:
			# Show OnOffToggleSection for standard disable
			$OnOffToggleSection.visible = true
			$OnOffToggleSection/CountdownLabel.bbcode_text = "[center]" + str(int(time_left)) + "[/center]"
			$FeedSettingsToggleSection.visible = false

		$NetworkToggleSection.visible = false
		$OnOff.visible = false
		$FeedSettings.visible = false
		$Network.visible = false
	else:
		# When the camera is neither in maintenance nor disabled, reset all sections to invisible
		$MaintenanceToggleSection.visible = false
		$OnOffToggleSection.visible = false
		$FeedSettingsToggleSection.visible = false
		$NetworkToggleSection.visible = false
		$OnOff.visible = true
		$FeedSettings.visible = true
		$Network.visible = true

	# Set the processing of the UI based on whether any section is visible
	set_process($MaintenanceToggleSection.visible || $OnOffToggleSection.visible || $FeedSettingsToggleSection.visible || $NetworkToggleSection.visible)

# Called when OnOff button is pressed
func _on_OnOff_pressed():
	camera_node.disable_camera()
	$OnOffToggleSection/CountdownLabel.text = str(int(camera_node.get_initial_wait_time()))
	$OnOffToggleSection.visible = true  # Make the section visible
	set_process(true)

# Called when ExitButton is pressed
func _on_ExitButton_pressed():
	# Inform the Player that the CameraUtility is no longer active
	var player_node = get_tree().get_root().find_node("Player", true, false)
	if player_node:
		player_node.set_watchson_active(false)
		player_node.set_watchson_ui_active(false)
	queue_free()

# Called every frame
func _process(delta):
	if showWarning:
		return

	# It's better to fetch the main_controller here again in case it changes.
	var main_controller = get_tree().get_root().find_node("QRF", true, false)
	if not main_controller:
		print("Main controller (QRF) not found.")
		set_process(false)  # Disable the process if we can't find the main controller
		return

	var maintenance_time_left = 0
	if main_controller.has_method("get_maintenance_time_left"):
		maintenance_time_left = main_controller.call("get_maintenance_time_left")

	if camera_node.isInMaintenance:
		# Only update the countdown label if it's visible (i.e., in maintenance mode)
		$MaintenanceToggleSection/CountdownLabel.bbcode_text = "[center]" + str(int(maintenance_time_left)) + "[/center]"
		# Ensure that only the MaintenanceToggleSection is visible
		$MaintenanceToggleSection.visible = true
		$OnOffToggleSection.visible = false
		$FeedSettingsToggleSection.visible = false
		$NetworkToggleSection.visible = false
		$OnOff.visible = false
		$FeedSettings.visible = false
		$Network.visible = false
	elif camera_node.isDisabled:
		var time_left = int(round(camera_node.get_time_left()))

		if camera_node.is_stream_replayed:
			# Show FeedSettingsToggleSection for stream replay
			$FeedSettingsToggleSection.visible = true
			$FeedSettingsToggleSection/CountdownLabel.bbcode_text = "[center]" + str(int(time_left)) + "[/center]"
			$OnOffToggleSection.visible = false
		else:
			# Show OnOffToggleSection for standard disable
			$OnOffToggleSection.visible = true
			$OnOffToggleSection/CountdownLabel.bbcode_text = "[center]" + str(int(time_left)) + "[/center]"
			$FeedSettingsToggleSection.visible = false

		$NetworkToggleSection.visible = false
		$OnOff.visible = false
		$FeedSettings.visible = false
		$Network.visible = false
	else:
		# Hide all toggle sections and show buttons if the camera is active and not in maintenance
		$MaintenanceToggleSection.visible = false
		$OnOffToggleSection.visible = false
		$FeedSettingsToggleSection.visible = false
		$NetworkToggleSection.visible = false
		$OnOff.visible = true
		$FeedSettings.visible = true
		$Network.visible = true

	# Set processing to true only if the camera is in maintenance or disabled
	set_process(camera_node.isInMaintenance || camera_node.isDisabled)


func _on_FeedSettings_pressed():
	$FeedSettingsToggleSection.visible = true
	$OnOff.visible = false
	$FeedSettings.visible = false
	$Network.visible = false
	camera_node.stream_replay()
	$FeedSettingsToggleSection/CountdownLabel.text = str(int(camera_node.get_initial_wait_time()))
	set_process(true)

# New function to handle Stream Replay failure
func _on_StreamReplay_failed():
	showWarning = true
	$FeedSettingsToggleSection/WarningLabel.visible = true
	$FeedSettingsToggleSection/CountdownLabel.visible = false
	$FeedSettingsToggleSection/InfoLabel.visible = false
	$FeedSettingsToggleSection.get_node("WarningTimer").start()

func _on_WarningTimer_timeout():
	$FeedSettingsToggleSection/WarningLabel.visible = false
	$FeedSettingsToggleSection/CountdownLabel.visible = true  # Make it visible again
	$FeedSettingsToggleSection/InfoLabel.visible = true       # Make it visible again
	$FeedSettingsToggleSection.visible = false
	$OnOff.visible = true
	$FeedSettings.visible = true
	$Network.visible = true
	showWarning = false
	$FeedSettingsToggleSection.visible = true  # Make it visible again


func _ready():
	update_ui()
	check_and_show_arrow()
	var player_node = get_tree().get_root().find_node("Player", true, false)
	if player_node:
		player_node.set_watchson_active(true)
		player_node.set_watchson_ui_active(true)
	var warning_timer = Timer.new()
	warning_timer.set_name("WarningTimer")
	warning_timer.set_one_shot(true)
	warning_timer.set_wait_time(2.0)
	warning_timer.connect("timeout", self, "_on_WarningTimer_timeout")
	$FeedSettingsToggleSection.add_child(warning_timer)
	for camera in get_tree().get_nodes_in_group("cameras"):
		camera.connect("body_detected", self, "_on_Camera_body_detected")
		camera.connect("body_no_longer_detected", self, "_on_Camera_body_no_longer_detected")

# Handler for Network button press
func _on_Network_pressed():
	var main_controller = get_tree().get_root().find_node("QRF", true, false)
	if main_controller and not main_controller.bot_instanced:
		instance_bot_at_position(Vector2(949, -5137))
		main_controller.bot_instanced = true
	print("Network button pressed")
	camera_node.check_for_moving_bodies()
	$NetworkToggleSection.visible = true  # Show the Network Toggle Section
	# Hide the other main buttons but keep the Exit button visible
	$OnOff.visible = false
	$FeedSettings.visible = false
	$Network.visible = false  # Hide the Network button itself
	# The Exit button remains visible

# Function to initialize flashing for a specific camera
func start_camera_flash(camera_name):
	stop_camera_flash(camera_name)  # Stop any existing timer first

	# Create a new Timer node
	var new_timer = Timer.new()
	new_timer.set_wait_time(0.5)  # Set the interval for flashing
	new_timer.set_one_shot(false)  # Ensure the timer loops
	new_timer.connect("timeout", self, "_on_FlashTimer_timeout", [camera_name])
	add_child(new_timer)
	new_timer.start()
	flash_timers[camera_name] = new_timer  # Store the timer in the dictionary

	print("Started flash for: ", camera_name)

# Handler for the flashing effect
func _on_FlashTimer_timeout(camera_name):
	var camera_sprite = $NetworkToggleSection.get_node(camera_name)
	if camera_sprite:
		camera_sprite.visible = !camera_sprite.visible

# When a moving body is detected
func _on_Camera_body_detected(camera_name):
	print("Body detected by: ", camera_name)
	start_camera_flash(camera_name)

func stop_camera_flash(camera_name):
	if camera_name in flash_timers:
		var timer = flash_timers[camera_name]
		if timer and not timer.is_queued_for_deletion():
			timer.stop()
			timer.queue_free()
		flash_timers.erase(camera_name)  # Remove the timer from the dictionary

		# Make sure the sprite is not visible
		var camera_sprite = $NetworkToggleSection.get_node_or_null(camera_name)
		if camera_sprite:
			camera_sprite.visible = false

		print("Stopped flash for: ", camera_name)


func _on_Camera_body_no_longer_detected(camera_name):
	print("Stopping flash for: ", camera_name)
	stop_camera_flash(camera_name)

func check_and_show_arrow():
	var main_controller = get_tree().get_root().find_node("QRF", true, false)
	if main_controller and not main_controller.arrow_shown:
		show_arrow_to_network_button()
		disable_other_buttons()
		main_controller.arrow_shown = true

func show_arrow_to_network_button():
	# Logic to show an arrow pointing to the network button
	# You would typically set `visible` to true on a Sprite node representing the arrow
	$Network/Arrow.visible = true

func disable_other_buttons():
	# Disable the 'Disable' and 'Stream Replay' buttons
	$OnOff.disabled = true
	$FeedSettings.disabled = true
	# You may also want to change their appearance to reflect the disabled state visually

func instance_bot_at_position(position):
	var bot_scene = preload("res://Scenes/Objects/Robots/Kinesys Sentinel.tscn")
	var bot_instance = bot_scene.instance()
	bot_instance.global_position = position
	
	var ysort_node = get_tree().get_root().find_node("YSort", true, false)
	if ysort_node:
		ysort_node.add_child(bot_instance)  # Add the bot to the YSort node
	else:
		print("YSort node not found. Bot not added.")
