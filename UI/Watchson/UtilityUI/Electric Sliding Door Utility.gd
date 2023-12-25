extends Control

var slidingDoorNode = null
var door_opening_initiated = false  # Track if the door opening process has been initiated

func _ready():
	$OpenButton.connect("pressed", self, "_on_OpenButton_pressed")
	$ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	update_ui()

func _on_OpenButton_pressed():
	if slidingDoorNode and not door_opening_initiated:
		slidingDoorNode.open_door()
		door_opening_initiated = true  # Mark that door opening has been initiated
		update_ui()
	elif door_opening_initiated:
		print("Door opening process already initiated.")

func _on_ExitButton_pressed():
	var player_node = get_tree().get_root().find_node("Player", true, false)
	if player_node:
		player_node.set_watchson_active(false)
		player_node.set_watchson_ui_active(false)
	queue_free()

func update_ui():
	# Toggle the visibility of the OpenButton and ToggleSection based on the door state
	$OpenButton.visible = not door_opening_initiated
	$ToggleSection.visible = door_opening_initiated

func init(slidingDoor):
	slidingDoorNode = slidingDoor
	door_opening_initiated = slidingDoorNode.door_opening_initiated if slidingDoorNode else false
	update_ui()
