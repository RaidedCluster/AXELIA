extends Node2D

var radar_active = false

func activate_radar():
	$AnimationPlayer.play("rotate_radar")
	radar_active = true
	for body in radar_area.get_overlapping_bodies():
		if body.is_in_group("hackable"):
			body.set_outline(true)
	emit_signal("radar_activated")

onready var radar_area = $RadarArea

func _ready():
	radar_area.connect("body_entered", self, "_on_RadarArea_area_entered")
	radar_area.connect("body_exited", self, "_on_RadarArea_area_exited")
	radar_area.connect("input_event", self, "_on_radar_area_input_event")

func _on_RadarArea_area_entered(body):
	if radar_active and body.is_in_group("hackable"):
		body.set_outline(true)

func _on_RadarArea_area_exited(body):
	if radar_active and body.is_in_group("hackable"):
		body.set_outline(false)

func deactivate_radar():
	$AnimationPlayer.stop()
	radar_active = false
	for body in radar_area.get_overlapping_bodies():
		if body.is_in_group("hackable"):
			body.set_outline(false)
	self.visible = false
	emit_signal("radar_deactivated")

func _input(event):
	if event.is_action_pressed("wui_escape") and radar_active:
		deactivate_radar()

func _on_radar_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var global_mouse_position = get_global_mouse_position()
		for body in radar_area.get_overlapping_bodies():
			if body.is_in_group("hackable"):
				var local_rect_size = Vector2()
				var offset = Vector2()
				
				if body.has_node("Sprite"):
					var sprite_node = body.get_node("Sprite")
					local_rect_size = sprite_node.texture.get_size()
					offset = sprite_node.offset
				elif body.has_node("AnimatedSprite"):
					var anim_sprite_node = body.get_node("AnimatedSprite")
					var current_animation = anim_sprite_node.animation
					var current_frame = anim_sprite_node.frame
					var sprite_frames = anim_sprite_node.frames
					if sprite_frames.has_animation(current_animation):
						local_rect_size = sprite_frames.get_frame(current_animation, current_frame).get_size()
						offset = anim_sprite_node.offset
				else:
					continue  # Skip if neither Sprite nor AnimatedSprite
				
				# Since Godot's coordinate system is y-down, a negative offset.y moves the sprite upwards.
				# To compensate and move the detection area down to the sprite, we add the offset.
				var adjusted_global_position = body.global_position + offset
				# Calculate the global bounding rect considering the sprite's offset
				var global_bounding_rect = Rect2(adjusted_global_position - local_rect_size / 2, local_rect_size)
				
				if global_bounding_rect.has_point(global_mouse_position):
					body.utility()
					deactivate_radar()  # Deactivate the radar here
					break





