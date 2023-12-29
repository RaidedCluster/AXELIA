extends Control

signal radar_button_pressed
signal recharge_drink_consumed

var watchswitch = false
var player = preload("res://Scenes/Characters/Player.tscn")
var watchson_gui = preload("res://UI/UI Scenes/WatchsonUI.tscn")
var isLogoAnimationPlayed = false

var can_interact_with_inventory = true
var tutorial3_played = false

var items = {
	'item1': 'action1',
	'item2': 'action2',
	'item3': 'action3'
}

# Define the inventory slots
var slots = ['item1', 'item2', 'item3']

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)
	$HBoxContainer/Slot1.connect("pressed", self, "_on_slot_pressed", [0])
	$HBoxContainer/Slot2.connect("pressed", self, "_on_slot_pressed", [1])
	$HBoxContainer/Slot3.connect("pressed", self, "_on_slot_pressed", [2])
	connect_to_vending_machine()
	connect_to_vending_machine_front()

func show_watchson_gui():
	if not has_node("watchson_gui_instance"):
		var watchson_gui_instance = watchson_gui.instance()
		watchson_gui_instance.name = "watchson_gui_instance"
		watchson_gui_instance.rect_position = Vector2(-140, 400)
		watchson_gui_instance.isLogoAnimationPlayed = isLogoAnimationPlayed
		add_child(watchson_gui_instance)
		watchson_gui_instance.connect("radar_button_pressed", self, "on_radar_button_pressed")
		# Find the player node and call set_watchson_active on it
		var player_node = get_tree().get_root().find_node("Player", true, false)
		if player_node:
			player_node.set_watchson_active(true)

func hide_watchson_gui():
	print("Hide Watchson GUI called.")
	if has_node("watchson_gui_instance"):
		var watchson_gui_instance = get_node("watchson_gui_instance")
		watchson_gui_instance.wui_fade_out()
		yield(watchson_gui_instance, "fade_out_completed")
		print("Fade-out completed.")
		watchson_gui_instance.queue_free()
		get_node("Watchson").move_down()
		# Find the player node and call set_watchson_active on it
		var player_node = get_tree().get_root().find_node("Player", true, false)
		if player_node:
			player_node.set_watchson_active(false)

# Inventory.gd

func perform_action1():
	if watchswitch == false:
		watchswitch = true
		get_node("Watchson").move_up()
		show_watchson_gui()
	else:
		watchswitch = false
		hide_watchson_gui()

func perform_action2():
	if !watchswitch:  # Check if Watchson UI is not active
		get_tree().paused = true  # Pause the game
		var new_dialog = Dialogic.start('BlackBox')  # Start the 'BlackBox' dialogue
		new_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
		add_child(new_dialog)
		new_dialog.connect("timeline_end", self, "on_dialogue_end")

func perform_action3():
	var player_node = get_tree().get_root().find_node("Player", true, false)
	if player_node and player_node.unlimited_stamina:
		# If the unlimited stamina effect is active, play a different dialogue
		var new_dialog = Dialogic.start('RechargeCan2')  # Assuming 'RechargeCan2' is the dialogue for this scenario
		new_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
		add_child(new_dialog)
		new_dialog.connect("timeline_end", self, "on_dialogue_end")
	elif $RechargeCan.visible:
		# Regular logic for consuming the RechargeCan
		$RechargeCan.visible = false
		get_tree().paused = true
		var new_dialog = Dialogic.start('RechargeCan')
		new_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
		add_child(new_dialog)
		new_dialog.connect("timeline_end", self, "on_dialogue_end")
		emit_signal("recharge_drink_consumed")
	else:
		print("No RechargeCan in inventory.")

#CHECK THIS PART NOT TOO SURE
func _on_slot_pressed(slot_index):
	if can_interact_with_inventory:
		var item = slots[slot_index]
		match items[item]:
			'action1':
				if not player.watchson_ui_active:
					perform_action1()
			'action2':
				if not player.watchson_ui_active:  # Only perform action2 if Watchson is not active
					perform_action2()
			'action3':
				if not player.watchson_ui_active:  # Only perform action3 if Watchson is not active
					perform_action3()


func on_radar_button_pressed():
	watchswitch = false
	toggle_radar_visibility()
	hide_watchson_gui()
	get_node("Watchson").move_down()
	
	if not tutorial3_played:
		disable_inventory_interaction()  # Disable inventory interaction
		var tutorial3_dialog = Dialogic.start('Tutorial3')
		tutorial3_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
		add_child(tutorial3_dialog)
		tutorial3_dialog.connect("timeline_end", self, "on_tutorial3_dialogue_end")
		tutorial3_played = true

func on_tutorial3_dialogue_end(timeline_name):
	enable_inventory_interaction()  # Re-enable inventory interaction
	# Any additional logic you want to execute after the dialogue ends
	var player = get_tree().get_root().find_node("Player", true, false)
	if player:
		player.enable_interaction()


func toggle_radar_visibility():
	var player = get_tree().get_root().find_node("Player", true, false)
	if player:
		var radar = player.find_node("Radar")
		if radar:
			radar.visible = !radar.visible
			if radar.visible:
				radar.activate_radar()
			else:
				radar.deactivate_radar()

func on_dialogue_end(timeline_name):
	get_tree().paused = false  # Resume the game when dialogue ends

func connect_to_vending_machine():
	var vending_machine = get_tree().get_root().find_node("Vending Machine", true, false)
	if vending_machine:
		vending_machine.connect("vending_machine_used", self, "_on_vending_machine_used")
	else:
		print("VendingMachine node not found!")

func connect_to_vending_machine_front():
	var vending_machine_front = get_tree().get_root().find_node("Vending Machine Front", true, false)
	if vending_machine_front:
		vending_machine_front.connect("vending_machine_front_used", self, "_on_vending_machine_front_used")
	else:
		print("VendingMachineFront node not found!")

func _on_vending_machine_used():
	$RechargeCan.visible = true

func _on_vending_machine_front_used():
	print("Vending Machine Front used - Signal received in Inventory")
	$RechargeCan.visible = true

# In Inventory.gd
func is_recharge_can_visible() -> bool:
	return $RechargeCan.visible

func disable_inventory_interaction():
	can_interact_with_inventory = false
	print("Inventory interaction disabled")

func enable_inventory_interaction():
	can_interact_with_inventory = true
	print("Inventory interaction enabled")
