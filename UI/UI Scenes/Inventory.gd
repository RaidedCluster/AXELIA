extends Control

signal radar_button_pressed

var watchswitch=false
var player=preload("res://Scenes/Characters/Player.tscn")
var watchson_gui = preload("res://UI/UI Scenes/WatchsonUI.tscn")

var items = {
	'item1': 'action1',
	'item2': 'action2',
	'item3': 'action3'
}

# Define the inventory slots
var slots = ['item1', 'item2', 'item3']

func _ready():
	# Connect the button signals to the _on_slot_pressed function
	$HBoxContainer/Slot1.connect("pressed", self, "_on_slot_pressed", [0])
	$HBoxContainer/Slot2.connect("pressed", self, "_on_slot_pressed", [1])
	$HBoxContainer/Slot3.connect("pressed", self, "_on_slot_pressed", [2])
	# Connect radar_button_pressed signal
	if has_node("watchson_gui_instance"):
		var watchson_gui_instance = get_node("watchson_gui_instance")
		watchson_gui_instance.connect("radar_button_pressed", self, "on_radar_button_pressed")

func show_watchson_gui():
	var watchson_gui_instance = watchson_gui.instance()
	watchson_gui_instance.name = "watchson_gui_instance"
	watchson_gui_instance.rect_position = Vector2(-140, 400)
	add_child(watchson_gui_instance)
	watchson_gui_instance.connect("radar_button_pressed", self, "on_radar_button_pressed")


func hide_watchson_gui():
	if has_node("watchson_gui_instance"):
		var watchson_gui_instance = get_node("watchson_gui_instance")
		watchson_gui_instance.wui_fade_out()
		yield(watchson_gui_instance.get_node("AnimationPlayer"), "animation_finished")
		watchson_gui_instance.queue_free()

func perform_action1():
	if watchswitch==false:
		watchswitch=true
		get_node("Watchson").move_up()
		show_watchson_gui()
		
	else:
		watchswitch=false
		hide_watchson_gui()
		get_node("Watchson").move_down()

func perform_action2():
	print("Item 2 clicked: Performing action 2")

func perform_action3():
	print("Item 3 clicked: Performing action 3")

func _on_slot_pressed(slot_index):
	# Get the item in the clicked slot
	var item = slots[slot_index]

	# Perform the action associated with the item
	match items[item]:
		'action1':
			perform_action1()
		'action2':
			perform_action2()
		'action3':
			perform_action3()

func on_radar_button_pressed():
	watchswitch=false
	toggle_radar_visibility()
	hide_watchson_gui()
	get_node("Watchson").move_down()

func toggle_radar_visibility():
	var player = get_tree().get_root().find_node("Player", true, false)
	if player:
		var radar = player.find_node("Radar") # Replace "Radar" with the actual name of the radar node
		if radar:
			radar.visible = !radar.visible
			if radar.visible:
				radar.activate_radar()
			elif radar.visible==false:
				radar.deactivate_radar()
