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

	# Update the UI based on the current state of the camera node
	update_ui()

func update_ui():
	var time_left = int(round(camera_node.get_time_left()))
	$OnOffToggleSection/CountdownLabel.text = str(time_left)
	$FeedSettingsToggleSection/CountdownLabel.text = str(time_left)
	# No countdown for NetworkToggleSection as per your requirements

	# Determine which UI elements to show based on the camera's state
	if camera_node.isDisabled:
		if camera_node.is_stream_replayed:
			$OnOffToggleSection.visible = false
			$FeedSettingsToggleSection.visible = true
		else:
			$OnOffToggleSection.visible = true
			$FeedSettingsToggleSection.visible = false
		$NetworkToggleSection.visible = false  # Ensure NetworkToggleSection is not visible when camera is disabled
		$OnOff.visible = false
		$FeedSettings.visible = false
		$Network.visible = false
	else:
		$OnOffToggleSection.visible = false
		$FeedSettingsToggleSection.visible = false
		$NetworkToggleSection.visible = false  # Reset NetworkToggleSection visibility when camera is not disabled
		$OnOff.visible = true
		$FeedSettings.visible = true
		$Network.visible = true

	set_process(camera_node.isDisabled || $OnOffToggleSection.visible || $FeedSettingsToggleSection.visible || $NetworkToggleSection.visible)


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
	queue_free()

# Called every frame
func _process(delta):
	if showWarning:
		return

	if camera_node.isDisabled:
		var time_left = int(round(camera_node.get_time_left()))
		if $OnOffToggleSection.visible:
			$OnOffToggleSection/CountdownLabel.bbcode_text = "[center]" + str(time_left) + "[/center]"
		if $FeedSettingsToggleSection.visible:
			$FeedSettingsToggleSection/CountdownLabel.bbcode_text = "[center]" + str(time_left) + "[/center]"
		$OnOff.visible = false
		$FeedSettings.visible = false
		$Network.visible = false
	else:
		$OnOffToggleSection.visible = false
		$FeedSettingsToggleSection.visible = false
		$OnOff.visible = true
		$FeedSettings.visible = true
		$Network.visible = true
		set_process(false)

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
	var player_node = get_tree().get_root().find_node("Player", true, false)
	if player_node:
		player_node.set_watchson_active(true)
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
	print("Network button pressed")
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
