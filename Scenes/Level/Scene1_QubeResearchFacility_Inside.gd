extends Node2D

# Dictionary to keep track of cameras
var disabled_cameras = {}
var maintenance_timer = Timer.new()

func _ready():
	print(get_tree().get_root().get_path_to(self))
	var cameras = get_tree().get_nodes_in_group("cameras")
	for camera in cameras:
		var error = camera.connect("disabled", self, "_on_Camera_disabled")
		if error == OK:
			print("Successfully connected disabled signal for camera: ", camera.name)
		else:
			print("Failed to connect disabled signal for camera: ", camera.name, " Error: ", error)
	maintenance_timer.set_wait_time(60.0)  # Set for 60 seconds
	maintenance_timer.set_one_shot(true)
	maintenance_timer.connect("timeout", self, "_on_MaintenanceTimer_timeout")
	add_child(maintenance_timer)

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

func get_maintenance_time_left():
	return maintenance_timer.time_left
