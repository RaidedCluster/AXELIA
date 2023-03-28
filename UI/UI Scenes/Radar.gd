extends Node2D

var radar_active = false

func activate_radar():
	$AnimationPlayer.play("rotate_radar")
	radar_active = true
	for body in radar_area.get_overlapping_bodies():
		if body.is_in_group("hackable"):
			body.set_outline(true)

onready var radar_area = $RadarArea

func _ready():
	radar_area.connect("body_entered", self, "_on_RadarArea_area_entered")
	radar_area.connect("body_exited", self, "_on_RadarArea_area_exited")

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

func _input(event):
	if event.is_action_pressed("wui_escape") and radar_active:
		deactivate_radar()
