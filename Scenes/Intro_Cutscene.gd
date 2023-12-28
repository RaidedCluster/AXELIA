extends Node2D

# Duration of the fade effect
var fade_duration = 1.0

# Nodes for city and keyboard images
onready var city_image = $City
onready var keyboard_image = $Keyboard
onready var _transition_rect = $SceneTransitionRect

# Tween nodes
onready var city_tween = city_image.get_node("Tween")
onready var keyboard_tween = keyboard_image.get_node("Tween")

# Dialogic timeline names
var city_dialogue_name = "IntroPt1"
var keyboard_dialogue_name = "IntroPt2"

func _ready():
	# Start with transparent images
	city_image.modulate = Color(1, 1, 1, 0)
	keyboard_image.modulate = Color(1, 1, 1, 0)

	# Begin the intro sequence
	start_intro_sequence()

func start_intro_sequence():
	# Fade in the city image
	fade_in(city_image, city_tween)
	yield(city_tween, "tween_completed") # Wait for fade in to complete

	# Start the city dialogue
	var city_dialog = Dialogic.start(city_dialogue_name)
	city_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(city_dialog)
	yield(city_dialog, "timeline_end") # Wait for dialogue to end

	# Fade out the city image
	fade_out(city_image, city_tween)
	yield(city_tween, "tween_completed") # Wait for fade out to complete

	# Fade in the keyboard image
	fade_in(keyboard_image, keyboard_tween)
	yield(keyboard_tween, "tween_completed") # Wait for fade in to complete

	# Start the keyboard dialogue
	var keyboard_dialog = Dialogic.start(keyboard_dialogue_name)
	keyboard_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(keyboard_dialog)
	yield(keyboard_dialog, "timeline_end") # Wait for dialogue to end
	# Proceed with additional actions after the keyboard dialogue ends
	_transition_rect.transition_to("res://Scenes/Level/Scene1_QubeResearchFacility_Inside.tscn")

func fade_in(node: Sprite, tween: Tween):
	tween.interpolate_property(node, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func fade_out(node: Sprite, tween: Tween):
	tween.interpolate_property(node, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


