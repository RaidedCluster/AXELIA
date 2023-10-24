extends StaticBody2D

signal caught

var detection_area
var animated_sprite
var disable_timer

var isDisabled = false
var outline_enabled = false
var outline_shader_material = preload("res://UI/UI Sprites/outline.tres")

# New variable to hold a reference to the UI
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
	animated_sprite = $AnimatedSprite
	connect("caught", self, "_on_player_caught")
	detection_area.connect("body_entered", self, "_on_DetectionArea_body_entered")
	
	# Manually create and configure the timer
	disable_timer = Timer.new()
	disable_timer.set_name("DisableTimer")
	disable_timer.set_wait_time(10.0)
	disable_timer.set_one_shot(true)
	disable_timer.connect("timeout", self, "_on_DisableTimer_timeout")
	add_child(disable_timer)


func disable_camera():
	isDisabled = true
	detection_area.monitoring = false
	animated_sprite.animation = "Off"
	animated_sprite.play()
	if disable_timer:
		disable_timer.stop()  # Ensure it's stopped
		disable_timer.start()  # Start the timer
		print("Timer started with time_left: ", disable_timer.time_left)  # Debugging print



func _on_DisableTimer_timeout():
	print("Timer timed out!")  # Debugging print
	isDisabled = false
	detection_area.monitoring = true
	animated_sprite.animation = "On"
	animated_sprite.play()


func _on_DetectionArea_body_entered(body):
	if not isDisabled and body.name == "Player":
		emit_signal("caught")

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
