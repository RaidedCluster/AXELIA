extends Control

# Variables to reference the Vending Machine and track the motor state
var vending_machine = null
var motor_started = false

# Ready function to connect signals and initialize the UI
func _ready():
	$StartMotorButton.connect("pressed", self, "_on_StartMotorButton_pressed")
	$ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	update_ui()

# Function called when the Start Motor button is pressed
func _on_StartMotorButton_pressed():
	if not motor_started:
		motor_started = true
		vending_machine.activate_motor()  # Call the function to activate the motor
	update_ui()

# Function to update the UI elements based on the motor state
func update_ui():
	# Hide the Start Motor button if the motor has started
	$StartMotorButton.visible = !motor_started
	# Show the ToggleSection if the motor has started
	$ToggleSection.visible = motor_started
	# Update the label based on the motor state
	if motor_started:
		$ToggleSection/InfoLabel.text = "[center]The motor is jammed.[/center]"

# Function called when the Exit button is pressed
func _on_ExitButton_pressed():
	queue_free()

# Initialization function to set the Vending Machine reference and motor state
func init(vending_machine_ref):
	vending_machine = vending_machine_ref
	motor_started = vending_machine.motor_activated
	update_ui()

