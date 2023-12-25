extends Control

# Variable to reference the Vending Machine
var vending_machine = null

# Ready function to connect signals and initialize the UI
func _ready():
	var player_node = get_tree().get_root().find_node("Player", true, false)
	if player_node:
		player_node.set_watchson_active(true)
		player_node.set_watchson_ui_active(true)
	$StartMotorButton.connect("pressed", self, "_on_StartMotorButton_pressed")
	$ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	update_ui()

# Function called when the Start Motor button is pressed
func _on_StartMotorButton_pressed():
	if not vending_machine.motor_activated:
		vending_machine.activate_motor()
	update_ui()

# Function to update the UI elements based on the motor state
func update_ui():
	if vending_machine.motor_activated:
		$StartMotorButton.visible = false
		$ToggleSection.visible = true
	else:
		$StartMotorButton.visible = true
		$ToggleSection.visible = false
		# No need to set the InfoLabel text here since it should show the default text set in the editor.
# Function called when the Exit button is pressed
func _on_ExitButton_pressed():
	var player_node = get_tree().get_root().find_node("Player", true, false)
	if player_node:
		player_node.set_watchson_active(false)
		player_node.set_watchson_ui_active(false)
	queue_free()

# Initialization function to set the Vending Machine reference
func init(vending_machine_ref):
	vending_machine = vending_machine_ref
	update_ui()
