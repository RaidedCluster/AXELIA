extends Control

var camera_node = null

# Initialize the script with the camera node
func init(camera):
	camera_node = camera
	# Connecting signals
	$OnOff.connect("pressed", self, "_on_OnOff_pressed")
	$ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	# Add other button signal connections here as needed.

# Called when OnOff button is pressed
func _on_OnOff_pressed():
	camera_node.disable_camera()
	$OnOffToggleSection/CountdownLabel.text = str(int(camera_node.get_initial_wait_time()))
	set_process(true)  # This will make the _process function run every frame



# Called when ExitButton is pressed
func _on_ExitButton_pressed():
	queue_free()  # Removes the CameraUtilityUI from the scene

# Called every frame
func _process(delta):
	# If the camera is disabled
	if camera_node.isDisabled:
		var time_left = int(round(camera_node.get_time_left()))
		$OnOffToggleSection/CountdownLabel.bbcode_text = "[center]" + str(time_left) + "[/center]"
		$OnOffToggleSection.visible = true
		$OnOff.visible = false
		$FeedSettings.visible = false
		$Network.visible = false
	else:
		$OnOffToggleSection.visible = false
		$OnOff.visible = true
		$FeedSettings.visible = true
		$Network.visible = true
		set_process(false)  # We stop the _process function when the camera is not disabled
