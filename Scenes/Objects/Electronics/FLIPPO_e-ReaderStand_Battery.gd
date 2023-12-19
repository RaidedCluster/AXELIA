extends StaticBody2D

onready var FlippoInteraction = $InteractionArea
var player = null
var e_reader_scene = preload("res://UI/UI Scenes/Flippo E-Reader.tscn")
onready var animated_sprite = $AnimatedSprite
var current_e_reader_instance = null
var inventory = null  # Reference to the inventory

func _ready():
	player = get_tree().get_root().find_node("Player", true, false)
	inventory = get_tree().get_root().find_node("Inventory", true, false)  # Find the inventory

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and player and not player.watchson_active and not current_e_reader_instance:
		var areas = FlippoInteraction.get_overlapping_areas()
		for area in areas:
			if area.get_name() == "Interaction Area":
				open_e_reader()
				break

func open_e_reader():
	get_tree().paused = true
	var new_dialog = Dialogic.start('Flippo2')
	new_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(new_dialog)
	new_dialog.connect("timeline_end", self, "resume")
	if inventory:
		inventory.visible = false  # Hide the inventory

func resume(timeline_name):
	get_tree().paused = false
	current_e_reader_instance = e_reader_scene.instance()
	current_e_reader_instance.visible = false
	current_e_reader_instance.set_references(player, self)
	var ui_canvas_layer_node = get_node("/root/QRF/UI")
	ui_canvas_layer_node.add_child(current_e_reader_instance)
	current_e_reader_instance.connect("put_down", self, "on_e_reader_put_down")
	animated_sprite.play("8")
	current_e_reader_instance.visible = true

func on_e_reader_put_down():
	animated_sprite.play("Full")
	if current_e_reader_instance:
		current_e_reader_instance.queue_free()
	current_e_reader_instance = null
	if inventory:
		inventory.visible = true  # Show the inventory
