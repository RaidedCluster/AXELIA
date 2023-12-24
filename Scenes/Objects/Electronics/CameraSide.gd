extends StaticBody2D

signal caught
signal body_detected(camera_name)
signal body_no_longer_detected
signal stream_replay_failed
signal disabled(camera_name)
signal maintenance_mode_changed

var is_stream_replayed = false
var isInMaintenance = false

var detection_area
var disable_timer
var stream_replay_single_check_timer
var isDisabled = false
var outline_enabled = false
var outline_shader_material = preload("res://UI/UI Sprites/outline.tres")

# New variable to hold a referene to the UI
var camera_utility_ui = null

func set_outline(enable):
	if enable and not outline_enabled:
		self.material = outline_shader_material
		outline_enabled = true
	elif not enable and outline_enabled:
		self.material = null
		outline_enabled = false

func _ready():
	detection_area = $DetectionArea
	connect("caught", self, "_on_player_caught")
	detection_area.connect("body_entered", self, "_on_DetectionArea_body_entered")
	detection_area.connect("body_exited", self, "_on_DetectionArea_body_exited")

	# Manually create and configure the timer
	disable_timer = Timer.new()
	disable_timer.set_name("DisableTimer")
	disable_timer.set_wait_time(10.0)
	disable_timer.set_one_shot(true)
	disable_timer.connect("timeout", self, "_on_DisableTimer_timeout")
	add_child(disable_timer)
	
	# Initialize the new timer for Stream Replay check
	stream_replay_single_check_timer = Timer.new()
	stream_replay_single_check_timer.set_name("StreamReplaySingleCheckTimer")
	stream_replay_single_check_timer.set_one_shot(true)
	stream_replay_single_check_timer.connect("timeout", self, "_on_StreamReplaySingleCheckTimer_timeout")
	add_child(stream_replay_single_check_timer)

func disable_camera():
	isDisabled = true
	detection_area.monitoring = false
	if disable_timer:
		disable_timer.stop()  # Ensure it's stopped
		disable_timer.start()  # Start the timer
		emit_signal("disabled", name)
		print("Disabled signal emitted for camera: ", name)
		print("Timer started with time_left: ", disable_timer.time_left)  # Debugging print



func _on_DisableTimer_timeout():
	print("Timer timed out!")  # Debugging print
	isDisabled = false
	is_stream_replayed = false
	detection_area.monitoring = true

func _on_DetectionArea_body_entered(body):
	if isDisabled:
		return  # Do nothing if the camera is disabled

	if body.name == "Player":
		emit_signal("caught")  # The existing functionality for catching the player

	if body.is_in_group("moving_bodies"):
		emit_signal("body_detected", self.name)  # Emit a new signal for moving bodies detected
		print(self.name)

func _on_DetectionArea_body_exited(body):
	if not isDisabled and "moving_bodies" in body.get_groups():
		emit_signal("body_no_longer_detected", name)

func utility():
	var camera_utility_scene = preload("res://UI/Watchson/UtilityUI/CameraUtilityUI.tscn")
	var camera_utility_instance = camera_utility_scene.instance()
	camera_utility_instance.init(self)  # Initialize first
	camera_utility_ui = camera_utility_instance  # Then store the reference
	get_node("/root/QRF/UI").add_child(camera_utility_instance)


func get_time_left():
	if disable_timer:
		return disable_timer.time_left
	return 0

func _on_player_caught():
	print("Player was caught!")

func get_initial_wait_time():
	if disable_timer:
		return disable_timer.wait_time
	return 0

func stream_replay():  # New function
	isDisabled = true
	is_stream_replayed = true
	detection_area.monitoring = false
	disable_timer.stop()
	disable_timer.set_wait_time(30.0)  # Set for 30 seconds
	disable_timer.start()
	var random_time = rand_range(0, 30)
	stream_replay_single_check_timer.set_wait_time(random_time)
	stream_replay_single_check_timer.start()

func _on_StreamReplaySingleCheckTimer_timeout():  # New function
	var chance = randf()
	if chance < 0.08:  # 8% chance of failure
		isDisabled = false
		is_stream_replayed = false
		detection_area.monitoring = true
		emit_signal("stream_replay_failed")

func check_for_moving_bodies():
	for body in detection_area.get_overlapping_bodies():
		if body.is_in_group("moving_bodies"):
			emit_signal("body_detected", self.name)


func enter_maintenance_mode():
	isDisabled = false  # Ensure the camera is not marked as disabled
	if disable_timer.is_stopped() == false:
		disable_timer.stop()  # Stop the disable timer if it's running
	isInMaintenance = true
	emit_signal("maintenance_mode_changed")
	detection_area.monitoring = false

func exit_maintenance_mode():
	isDisabled = false
	isInMaintenance = false
	emit_signal("maintenance_mode_changed")
	detection_area.monitoring = true

