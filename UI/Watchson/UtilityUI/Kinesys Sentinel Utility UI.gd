extends Control

var sentinel_node = null

func _ready():
	$ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	$HaywireButton.connect("pressed", self, "_on_HaywireButton_pressed")
	update_ui()

func _on_HaywireButton_pressed():
	if not sentinel_node.haywire_executed:
		sentinel_node.go_haywire()
		update_ui()

func _on_ExitButton_pressed():
	queue_free()

func update_ui():
	if sentinel_node != null:
		# Show the ToggleSection only if the sentinel has been hacked
		$ToggleSection.visible = sentinel_node.haywire_executed
		# Hide the Haywire button if the sentinel has been hacked
		$HaywireButton.visible = !sentinel_node.haywire_executed

func init(sentinel):
	sentinel_node = sentinel
	update_ui()
