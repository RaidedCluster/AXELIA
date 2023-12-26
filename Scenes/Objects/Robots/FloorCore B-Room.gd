extends KinematicBody2D

onready var FloorCoreInteraction = $InteractionArea
var outline_enabled = false
var outline_shader_material = preload("res://UI/UI Sprites/outline.tres")
var player = null

var is_free_roaming = false
var move_speed = 100  # Adjust as needed
var change_direction_delay = 2.0  # Seconds
var next_direction_change = 0
var current_direction = Vector2()
var recent_directions = []  # Store recent directions

func set_outline(enable):
	if enable and not outline_enabled:
		self.material = outline_shader_material
		outline_enabled = true
	elif not enable and outline_enabled:
		self.material = null
		outline_enabled = false

func _ready():
	randomize()
	player = get_tree().get_root().find_node("Player", true, false)
	connect("interacted", self, "_process")

func _process(delta):
	if is_free_roaming:
		_handle_free_roam_movement(delta)

	if Input.is_action_just_pressed("ui_accept") and player and not player.watchson_active:
		var areas = FloorCoreInteraction.get_overlapping_areas()
		for area in areas:
			if area.get_name() == "Interaction Area":
				get_tree().paused = true
				var new_dialog = Dialogic.start('FloorCore')
				new_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
				add_child(new_dialog)
				new_dialog.connect("timeline_end", self, "resume")

func resume(timeline_name):
	get_tree().paused = false
	disconnect("interacted", self, "_process")

func _handle_free_roam_movement(delta):
	if OS.get_ticks_msec() > next_direction_change:
		_change_direction()
		next_direction_change = OS.get_ticks_msec() + change_direction_delay * 1000

	move_and_slide(current_direction * move_speed)

func _change_direction():
	var possible_directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	possible_directions.shuffle()
	
	for direction in possible_directions:
		if not direction in recent_directions:
			current_direction = direction
			_set_animation_for_direction(direction)
			_update_recent_directions(direction)
			return
	# Fallback if all adjacent directions are in recent memory
	current_direction = possible_directions[0]
	_set_animation_for_direction(current_direction)

func _set_animation_for_direction(direction):
	var animated_sprite = $AnimatedSprite
	if direction == Vector2(1, 0):  # Right
		animated_sprite.play("right")
	elif direction == Vector2(-1, 0):  # Left
		animated_sprite.play("left")
	elif direction == Vector2(0, 1):  # Down
		animated_sprite.play("down")
	elif direction == Vector2(0, -1):  # Up
		animated_sprite.play("up")

func _update_recent_directions(new_direction):
	recent_directions.append(new_direction)
	if recent_directions.size() > 5:  # Keep track of the last 5 directions
		recent_directions.pop_front()

func start_free_roam_mode():
	if not is_free_roaming:
		$Vacuuming.play()
		is_free_roaming = true
		_change_direction()  # Set initial direction
		add_to_group("moving_bodies")

# Utility function
func utility():
	var floorCoreUtilityScene = preload("res://UI/Watchson/UtilityUI/FloorCore B-Room Utility.tscn")
	var floorCoreUtilityInstance = floorCoreUtilityScene.instance()
	floorCoreUtilityInstance.init(self)
	get_node("/root/QRF/UI").add_child(floorCoreUtilityInstance)


