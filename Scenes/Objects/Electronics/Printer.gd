extends Sprite

onready var PrinterInteraction=$InteractionArea
var player = null

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)
	connect("interacted",self,"_process")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and player and not player.watchson_active:
		var areas=PrinterInteraction.get_overlapping_areas()
		for area in areas:
			if area.get_name()=="Interaction Area":
				get_tree().paused = true
				var new_dialog=Dialogic.start('Printer')
				new_dialog.pause_mode=Node.PAUSE_MODE_PROCESS
				add_child(new_dialog)
				new_dialog.connect("timeline_end",self,"resume")

func resume(timeline_name):
	get_tree().paused = false
