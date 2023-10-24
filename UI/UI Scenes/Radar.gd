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
				var local_rect
				if body.has_node("Sprite"):
					var sprite_node = body.get_node("Sprite")
					local_rect = sprite_node.texture.get_size()
				elif body.has_node("AnimatedSprite"):
					var anim_sprite_node = body.get_node("AnimatedSprite")
					var frame = anim_sprite_node.frames.get_frame(anim_sprite_node.animation, anim_sprite_node.frame)
					local_rect = frame.get_size()
				else:
					continue  # Skip if neither Sprite nor AnimatedSprite
				
				var global_bounding_rect = Rect2(body.global_position - local_rect / 2, local_rect)
				
				if global_bounding_rect.has_point(global_mouse_position):
					body.utility()
					deactivate_radar()  # Deactivate the radar here
					break






