extends StaticBody2D

# References to necessary nodes
onready var doorAnimation = $AnimatedSprite
onready var doorCollision = $DoorCloseCollision/CollisionShape2D
var outline_enabled = false
var outline_shader_material = preload("res://UI/UI Sprites/outline.tres")
var door_opening_initiated = false

func _ready():
	var main_controller = get_tree().get_root().find_node("QRF", true, false)
	if main_controller:
		main_controller.connect("player_caught_changed", self, "_on_Player_Caught_Changed")

func set_outline(enable):
	if enable and not outline_enabled:
		self.material = outline_shader_material
		outline_enabled = true
	elif not enable and outline_enabled:
		self.material = null
		outline_enabled = false

func open_door():
	# Access the main level controller's instance and check if the player is caught
	var main_controller = get_tree().get_root().find_node("QRF", true, false)
	if main_controller and main_controller.player_caught:
		print("Player is caught. Door stays closed.")
		return

	if not door_opening_initiated:
		door_opening_initiated = true
		var timer = Timer.new()
		timer.wait_time = 45  # 45 seconds delay
		timer.one_shot = true
		add_child(timer)
		timer.start()
		timer.connect("timeout", self, "_on_timer_timeout")

func _on_timer_timeout():
	# Check if the player has been caught when the timer expires
	var main_controller = get_tree().get_root().find_node("QRF", true, false)
	if main_controller and not main_controller.player_caught:
		doorAnimation.play("open")
		doorCollision.disabled = true
	else:
		print("Player is caught. Keeping the door closed.")
	# Reset door_opening_initiated regardless of whether the door opens or not
	door_opening_initiated = false

func close_door():
	doorAnimation.play("close")
	doorCollision.disabled = false

# Utility function for UI interaction
func utility():
	var slidingDoorUtilityScene = preload("res://UI/Watchson/UtilityUI/Electric Sliding Door Utility.tscn")
	var slidingDoorUtilityInstance = slidingDoorUtilityScene.instance()
	slidingDoorUtilityInstance.init(self)
	get_node("/root/QRF/UI").add_child(slidingDoorUtilityInstance)

func _on_Player_Caught_Changed(is_caught):
	if is_caught and doorAnimation.animation == "open":
		close_door()
