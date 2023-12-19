extends KinematicBody2D

const SPEED = 280
const CHANGE_DIRECTION_TIME_MIN = 1.0
const CHANGE_DIRECTION_TIME_MAX = 3.0
const TARGET_REACHED_THRESHOLD = 10.0
const PLAYER_UPDATE_THRESHOLD = 50.0
const DIRECTION_LERP_WEIGHT = 0.1
const sprite_height = -370

var velocity = Vector2.ZERO
var random_direction_timer := Timer.new()
var patrol_timer := Timer.new()  # Timer for patrolling a point
var player: KinematicBody2D
var player_detected = false
var last_known_player_position = Vector2()
var current_direction = Vector2.ZERO

var path = PoolVector2Array()
var path_index = 0

var haywire_executed = false

onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var detection_area: Area2D = $DetectionPivot/DetectionArea
onready var navigation2D: Navigation2D = get_tree().get_root().find_node("Navigation2D", true, false)
onready var ray_to_player = $RayCast2D
# Patrol points and state
var patrol_points = [Vector2(984, -5128), Vector2(2104, -4352), Vector2(1152, -4464), Vector2(1184, -2752), Vector2(3160, -2304), Vector2(984, -1368), Vector2(-216, -1192), Vector2(936, 528)]
var patrol_index = 0
var patrol_direction = 1  # 1 for forward, -1 for reverse
var is_patrolling = false  # New variable to check if currently patrolling

var outline_enabled = false
var outline_shader_material = preload("res://UI/UI Sprites/outline.tres")

func _ready():
	randomize()
	random_direction_timer.wait_time = rand_range(CHANGE_DIRECTION_TIME_MIN, CHANGE_DIRECTION_TIME_MAX)
	random_direction_timer.connect("timeout", self, "_on_random_direction_timer_timeout")
	add_child(random_direction_timer)
	random_direction_timer.start()
	
	for camera in get_tree().get_nodes_in_group("cameras"):
		camera.connect("caught", self, "_on_Camera_caught")
	
	patrol_timer.connect("timeout", self, "_on_patrol_timer_timeout")
	add_child(patrol_timer)
	
	animation_tree.active = true
	detection_area.connect("body_entered", self, "_on_Body_entered")
	detection_area.connect("body_exited", self, "_on_Body_exited")
	calculate_next_patrol_point()  # Initialize the first patrol point

func _physics_process(delta):
	if player_detected and player:
		if player.global_position.distance_to(last_known_player_position) > PLAYER_UPDATE_THRESHOLD:
			update_path_to_player()
			last_known_player_position = player.global_position
		follow_path(delta)
	elif not player_detected:
		follow_path(delta)
	velocity = move_and_slide(velocity)
	update_animation(velocity)
	update()

func calculate_next_patrol_point():
	path = navigation2D.get_simple_path(global_position, patrol_points[patrol_index], false)
	path_index = 0
	patrol_index += patrol_direction
	if patrol_index >= patrol_points.size() or patrol_index < 0:
		patrol_direction *= -1  # Reverse the direction of patrol
		patrol_index = max(min(patrol_index, patrol_points.size() - 1), 0)
	is_patrolling = true  # Start patrolling
	patrol_timer.start(20)  # Start the patrol timer for 20 seconds

func update_path_to_player():
	var offset_global_position = global_position + Vector2(0, -sprite_height / 2)
	var offset_player_position = player.global_position + Vector2(0, -sprite_height / 2)
	path = navigation2D.get_simple_path(offset_global_position, offset_player_position, true)
	path_index = 0

func follow_path(delta):
	if path_index < path.size():
		var target = path[path_index] + Vector2(0, sprite_height / 2)
		var direction = (target - global_position). normalized()
		velocity = direction * SPEED
		if global_position.distance_to(target) < TARGET_REACHED_THRESHOLD:
			path_index += 1
			if path_index >= path.size() and not player_detected:
				calculate_next_patrol_point()
	else:
		velocity = Vector2.ZERO

func update_animation(velocity: Vector2):
	var target_direction = velocity.normalized()
	current_direction = current_direction.linear_interpolate(target_direction, DIRECTION_LERP_WEIGHT)
	if current_direction.length() > 0.1:
		animation_tree.set("parameters/Idle/blend_position", current_direction)
		animation_tree.set("parameters/Walk/blend_position", current_direction)
		if velocity.length() > 0:
			animation_state.travel("Walk")
		else:
			animation_state.travel("Idle")
	else:
		animation_state.travel("Idle")

func _on_random_direction_timer_timeout():
	if not player_detected and not is_patrolling:
		patrol_index = randi() % patrol_points.size()
		calculate_next_patrol_point()
	random_direction_timer.wait_time = rand_range(CHANGE_DIRECTION_TIME_MIN, CHANGE_DIRECTION_TIME_MAX)
	random_direction_timer.start()

func _on_Body_entered(body):
	if body.name == "Player":
		ray_to_player.cast_to = body.global_position - global_position
		ray_to_player.force_raycast_update()  # Update the raycast to get the latest collision information
		
		if not ray_to_player.is_colliding():
			player = body
			player_detected = true
			random_direction_timer.stop()
		else:
			var collider = ray_to_player.get_collider()
			if collider is TileMap:  # Or check if collider is part of "Walls" group or layer
				# There is a wall between the player and the bot, don't chase
				pass
			else:
				# It's not a wall, so chase the player
				player = body
				player_detected = true
				random_direction_timer.stop()


func _on_Body_exited(body):
	if body.name == "Player":
		# Keep chasing the player after they exit the detection area
		pass

func _on_patrol_timer_timeout():
	is_patrolling = false  # Patrol finished at current point

func _draw():
	if path.size() > 1:
		var local_from
		var local_to
		for i in range(path.size() - 1):
			local_from = to_local(path[i])
			local_to = to_local(path[i + 1])
			draw_line(local_from, local_to, Color(1, 0, 0), 2)

func set_outline(enable):
	if enable and not outline_enabled:
		self.material = outline_shader_material
		outline_enabled = true
	elif not enable and outline_enabled:
		self.material = null
		outline_enabled = false

# This method is called when the bot goes haywire.
func go_haywire():
	if haywire_executed:
		return
	haywire_executed = true
	var will_dance = randi() % 42 == 0
	var animation_name = "Dancing" if will_dance else "Glitching"
	
	$AnimationPlayer.play(animation_name)
	var haywire_duration = 40.0 if will_dance else 10.0
	
	set_physics_process(false)
	yield(get_tree().create_timer(haywire_duration), "timeout")

	# Stop any animation that might be playing in AnimationPlayer
	$AnimationPlayer.stop()
	
	if player == null or not player.is_inside_tree():
		player = find_player()  # Implement this method to find and return the player
	if player != null:
		player_detected = true
		update_path_to_player()
	
	set_physics_process(true)
	reset_blend_position()

func utility():
	var sentinelUtilityScene = preload("res://UI/Watchson/UtilityUI/Kinesys Sentinel Utility UI.tscn")
	var sentinelUtilityInstance = sentinelUtilityScene.instance()
	# Initialize the utility with a reference to this sentinel
	sentinelUtilityInstance.init(self)
	# Add the utility instance to the UI layer of your game
	get_node("/root/QRF/UI").add_child(sentinelUtilityInstance)

func reset_blend_position():
	if current_direction != Vector2.ZERO:
		var blend_position = current_direction.normalized()
		animation_tree.set("parameters/Idle/blend_position", blend_position)
		animation_tree.set("parameters/Walk/blend_position", blend_position)
		animation_state.travel("Walk")
	else:
		animation_state.travel("Idle")

func find_player():
	# Assuming the player node is named "Player" and is active in the scene
	# Adjust the path or method of finding the player as needed for your game
	return get_tree().get_root().find_node("Player", true, false)

func _on_Camera_caught():
	player_detected = true
	if player == null or not player.is_inside_tree():
		player = find_player()
	if player != null:
		update_path_to_player()
