extends Node

var is_first_playthrough = true

func reset_game_state():
	is_first_playthrough = true

func start_retry():
	is_first_playthrough = false
