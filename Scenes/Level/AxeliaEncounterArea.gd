extends Area2D

var has_triggered_turing_test = false

func _ready():
	# Connect the body_entered signal to the _on_AxeliaEncounterArea_body_entered function
	connect("body_entered", self, "_on_AxeliaEncounterArea_body_entered")

func _on_AxeliaEncounterArea_body_entered(body):
	if body.name == "Player" and not has_triggered_turing_test:
		disable_player_and_inventory()
		has_triggered_turing_test = true
		yield(get_tree().create_timer(2.0), "timeout")
		trigger_turing_test_dialogue()
		trigger_terminal_monitor_animation()
		teleport_and_activate_bot()

func disable_player_and_inventory():
	var inventory = get_tree().get_root().find_node("Inventory", true, false)
	var player = get_tree().get_root().find_node("Player", true, false)
	if inventory:
		inventory.disable_inventory_interaction()
	if player:
		player.disable_interaction()

func trigger_turing_test_dialogue():
	var dialogue = Dialogic.start('TuringTest')  # Replace 'TuringTest' with your dialogue's name
	dialogue.pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().root.add_child(dialogue)  # Add the dialogue to the scene tree

func trigger_terminal_monitor_animation():
	var terminal_monitor = get_tree().get_root().find_node("Terminal Monitor", true, false)
	if terminal_monitor and terminal_monitor is AnimatedSprite:
		terminal_monitor.play("On")  # Assuming 'On' is the name of the animation

func teleport_and_activate_bot():
	var bot = get_tree().get_root().find_node("Kinesys Sentinel", true, false)
	if bot:
		bot.teleport_and_detect_player(Vector2(928, -11304))
