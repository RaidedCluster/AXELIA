extends Node2D

func _ready():
	yield(get_tree().create_timer(6.0), "timeout")  # Wait for 6 seconds
	get_tree().change_scene("res://Scenes/Title_Screen.tscn")  # Replace with the path to your title screen scene
