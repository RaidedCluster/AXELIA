extends StaticBody2D

onready var VendingMachineInteraction=$InteractionArea

func _ready():
	connect("body_entered",self,"_on_body_enter")
	connect("process",self,"_process")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var areas=VendingMachineInteraction.get_overlapping_areas()
		for area in areas:
			if area.get_name()=="Interaction Area":
				get_tree().paused = true
				var new_dialog=Dialogic.start('VendingMachine')
				new_dialog.pause_mode=Node.PAUSE_MODE_PROCESS
				add_child(new_dialog)
				new_dialog.connect("timeline_end",self,"resume")

func resume(timeline_name):
	get_tree().paused = false
