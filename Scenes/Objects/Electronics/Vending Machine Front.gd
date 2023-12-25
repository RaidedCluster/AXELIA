extends StaticBody2D

var outline_enabled = false
var outline_shader_material = preload("res://UI/UI Sprites/outline.tres")
var player = null 

var motor_activated = false
var has_played_hacked_dialogue = false
var can_dispensed = false

# In VendingMachine.gd
signal vending_machine_front_used

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
	if Input.is_action_just_pressed("ui_accept") and player and not player.watchson_active:
		var areas = VendingMachineInteraction.get_overlapping_areas()
		var dialog_name = ""  # Declare dialog_name at the start of the function
		for area in areas:
			if area.get_name() == "Interaction Area":
				if motor_activated:
					if not can_dispensed:
						var inventory = get_tree().root.find_node("Inventory", true, false)
						if inventory and inventory.is_recharge_can_visible():
							# If the RechargeCan is visible, play "Handful"
							dialog_name = "Handful"
						else:
							# If the RechargeCan is not visible, dispense can and play "HackedVendingMachine"
							emit_signal("vending_machine_front_used")
							dialog_name = "HackedVendingMachineFront"
							can_dispensed = true  # Indicate that this machine has dispensed a can
					else:
						# If this machine has already dispensed a can, play "PostHackedVendingMachine"
						dialog_name = "PostHackedVendingMachine"
				else:
					# If the vending machine hasn't been hacked, play "VendingMachine"
					dialog_name = "VendingMachineFront"
				
				var new_dialog = Dialogic.start(dialog_name)
				new_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
				add_child(new_dialog)
				new_dialog.connect("timeline_end", self, "resume")
				get_tree().paused = true


func resume(timeline_name):
	get_tree().paused = false
	disconnect("interacted",self,"_process")

# Utility function
func utility():
	var vendingMachineUtilityScene = preload("res://UI/Watchson/VendingMachineUtilityUI.tscn")
	var vendingMachineUtilityInstance = vendingMachineUtilityScene.instance()
	vendingMachineUtilityInstance.init(self)
	get_node("/root/QRF/UI").add_child(vendingMachineUtilityInstance)  # Make sure this path is correct
	
func activate_motor():
	if not motor_activated:
		# Logic to start the motor and dispense a drink
		motor_activated = true
