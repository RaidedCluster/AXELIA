extends KinematicBody2D

onready var FloorCoreInteraction=$InteractionArea
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
	connect("interacted",self,"_process")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var areas=FloorCoreInteraction.get_overlapping_areas()
		for area in areas:
			if area.get_name()=="Interaction Area":
				get_tree().paused = true
				var new_dialog=Dialogic.start('FloorCore')
				new_dialog.pause_mode=Node.PAUSE_MODE_PROCESS
				add_child(new_dialog)
				new_dialog.connect("timeline_end",self,"resume")

func resume(timeline_name):
	get_tree().paused = false
	disconnect("interacted",self,"_process")
