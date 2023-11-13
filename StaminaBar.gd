extends ProgressBar

onready var hide_timer = $HideTimer
onready var tween = $Tween
onready var bolt = $Bolt  # Reference to the Sprite node named "Bolt"

# Function to update the visual representation of the stamina.
func update_stamina(value: float) -> void:
	self.value = value

	# If stamina is full and the hide timer is not running, start the timer.
	if value == max_value and hide_timer.is_stopped():
		hide_timer.start()
	# If the stamina is not full, show and reset everything.
	elif value < max_value:
		show()
		bolt.show()
		hide_timer.stop()
		if tween.is_active():
			tween.stop_all()
		modulate.a = 1  # Reset the opacity to full
		bolt.modulate.a = 1  # Reset the opacity of the bolt to full

func _ready():
	hide_timer.wait_time = 2  # Set the timer to 2 seconds
	hide_timer.one_shot = true  # Make sure it doesn't repeat
	hide_timer.connect("timeout", self, "_on_hide_timer_timeout")

func _on_hide_timer_timeout():
	# Start the fade out using the tween for both the StaminaBar and the Bolt Sprite.
	tween.interpolate_property(self, "modulate", 
							   modulate, 
							   Color(modulate.r, modulate.g, modulate.b, 0), 
							   1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(bolt, "modulate", 
							   bolt.modulate, 
							   Color(bolt.modulate.r, bolt.modulate.g, bolt.modulate.b, 0), 
							   1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
