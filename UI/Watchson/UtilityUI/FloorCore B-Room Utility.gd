extends Control
var floorCoreNode = null
var free_roam_enabled = false
func _ready():
	var player_node = get_tree().get_root().find_node("Player", true, false)
	if player_node:
		player_node.set_watchson_active(true)
		player_node.set_watchson_ui_active(true)
	$FreeRoamButton.connect("pressed", self, "_on_FreeRoamButton_pressed")
	$ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	update_ui()

func _on_FreeRoamButton_pressed():
	if not free_roam_enabled:
		free_roam_enabled = true
		floorCoreNode.start_free_roam_mode()
		update_ui()

func _on_ExitButton_pressed():
	var player_node = get_tree().get_root().find_node("Player", true, false)
	if player_node:
		player_node.set_watchson_active(false)
		player_node.set_watchson_ui_active(false)
	queue_free()

func update_ui():
	# Show the ToggleSection only if free roam is enabled
	$ToggleSection.visible = free_roam_enabled
	# Hide the Free Roam button if free roam is enabled
	$FreeRoamButton.visible = !free_roam_enabled
func init(floorCore):
	floorCoreNode = floorCore
	free_roam_enabled = floorCoreNode.is_free_roaming
	update_ui()
