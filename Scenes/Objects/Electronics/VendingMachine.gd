extends StaticBody2D

var outline_enabled = false
var outline_shader_material = preload("res://UI/UI Sprites/outline.tres")
var player = null 

func set_outline(enable):
	if enable and not outline_enabled:
		self.material=outline_shader_material
		outline_enabled = true
	elif not enable and outline_enabled:
		self.material=null
		outline_enabled = false

onready var VendingMachineInteraction=$InteractionArea

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)  # Find the player node in the scene
	connect("process", self, "_process")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and player and not player.watchson_active:  # Check if Watchson is not active
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
	disconnect("interacted",self,"_process")
