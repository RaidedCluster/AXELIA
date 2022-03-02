extends CanvasLayer

export(String, FILE, "*.tscn") var next_scene_path

onready var _anim_player = $AnimationPlayer

func _ready():
	_anim_player.play("Fade_In")

func transition_to(_next_scene = next_scene_path):
	_anim_player.play("Fade_Out")
	yield(_anim_player, "animation_finished")
	get_tree().change_scene(_next_scene)
	_anim_player.play("Fade_In")
