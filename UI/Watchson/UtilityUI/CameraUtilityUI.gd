extends Control

var camera_node = null
var showWarning = false  # New variable to control the warning display

# Initialize the script with the camera node
func init(camera):
	camera_node = camera
	$OnOff.connect("pressed", self, "_on_OnOff_pressed")
	$ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	$FeedSettings.connect("pressed", self, "_on_FeedSettings_pressed")
	camera_node.connect("stream_replay_failed", self, "_on_StreamReplay_failed")

	# Update the UI based on the current state of the camera node
	update_ui()

func update_ui():
	var time_left = int(round(camera_node.get_time_left()))

	$OnOffToggleSection/CountdownLabel.text = str(time_left)
	$FeedSettingsToggleSection/CountdownLabel.text = str(time_left)

	# Determine which UI elements to show based on the camera's state
	if camera_node.isDisabled:
		if camera_node.is_stream_replayed:
			# The camera is in stream replay mode
			$OnOffToggleSection.visible = false
			$FeedSettingsToggleSection.visible = true
			set_process(true)
		else:
			# The camera is in regular disable mode
			$OnOffToggleSection.visible = true
			$FeedSettingsToggleSection.visible = false
			set_process(true)
		# Hide the main buttons when the camera is disabled
		$OnOff.visible = false
		$FeedSettings.visible = false
		$Network.visible = false
	else:
		# Camera is not disabled, show the main buttons
		$OnOffToggleSection.visible = false
		$FeedSettingsToggleSection.visible = false
		$OnOff.visible = true
		$FeedSettings.visible = true
		$Network.visible = true
		set_process(false)


# Called when OnOff button is pressed
func _on_OnOff_pressed():
	camera_node.disable_camera()
	$OnOffToggleSection/CountdownLabel.text = str(int(camera_node.get_initial_wait_time()))
	$OnOffToggleSection.visible = true  # Make the section visible
	set_process(true)


# Called when ExitButton is pressed
func _on_ExitButton_pressed():
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
	var warning_timer = Timer.new()
	warning_timer.set_name("WarningTimer")
	warning_timer.set_one_shot(true)
	warning_timer.set_wait_time(2.0)
	warning_timer.connect("timeout", self, "_on_WarningTimer_timeout")
	$FeedSettingsToggleSection.add_child(warning_timer)
