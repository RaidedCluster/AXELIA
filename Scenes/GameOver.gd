extends Node2D

func _ready():
	# Connect the 'pressed' signal of the Main Menu button to the on_MainMenuButton_pressed method
	$"Main Menu".connect("pressed", self, "on_MainMenuButton_pressed")
	$"Retry".connect("pressed", self, "on_RetryButton_pressed")
func on_MainMenuButton_pressed():
	# This function will be called when the Main Menu button is pressed
	# Change the scene to the Main Menu
	get_tree().change_scene("res://Scenes/Title_Screen.tscn")

func on_RetryButton_pressed():
	# Set the global variable to indicate it's a retry, not a first playthrough
	Global.is_first_playthrough = false

	# Change the scene back to your main level scene
	get_tree().change_scene("res://Scenes/Level/Scene1_QubeResearchFacility_Inside.tscn")
