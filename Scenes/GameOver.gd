extends Node2D

func _ready():
	# Connect the 'pressed' signal of the Main Menu button to the on_MainMenuButton_pressed method
	$"Main Menu".connect("pressed", self, "on_MainMenuButton_pressed")
	# Add the connection for the Retry button here if needed

func on_MainMenuButton_pressed():
	# This function will be called when the Main Menu button is pressed
	# Change the scene to the Main Menu
	get_tree().change_scene("res://Scenes/Title_Screen.tscn")
