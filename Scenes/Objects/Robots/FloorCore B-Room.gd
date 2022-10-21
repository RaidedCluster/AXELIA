extends KinematicBody2D

onready var FloorCoreInteraction=$InteractionArea

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
