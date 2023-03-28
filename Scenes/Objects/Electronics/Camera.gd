extends StaticBody2D

signal caught

onready var detection_area = $DetectionArea

var outline_enabled = false
var outline_shader_material = preload("res://UI/UI Sprites/outline.tres")

func set_outline(enable):
	if enable and not outline_enabled:
		self.material=outline_shader_material
		outline_enabled = true
	elif not enable and outline_enabled:
		self.material=null
		outline_enabled = false

func _ready():
	detection_area.connect("body_entered", self, "_on_DetectionArea_body_entered")

func _on_DetectionArea_body_entered(body):
	if body.name == "Player": # Replace "Player" with the actual name of the player node
		emit_signal("caught")
		print("caught")
