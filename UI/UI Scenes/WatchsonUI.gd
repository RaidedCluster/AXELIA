extends Control

signal radar_button_pressed
signal fade_out_completed

enum Mode {RADAR, QUESTION}
var active_mode = Mode.RADAR
var startup_finished = false
var isLogoAnimationPlayed = false

func start_up():
	if not isLogoAnimationPlayed:
		play_qube_fade()
		yield($AnimationPlayer, "animation_finished")
		isLogoAnimationPlayed = true
	play_radar_fade_in()
	startup_finished = true

func play_qube_fade():
	$AnimationPlayer.play("qube_fade")

func play_radar_fade_in():
	$AnimationPlayer.play("radar_fade_in")
	yield($AnimationPlayer, "animation_finished")
	$Radar.visible = true

func play_radar_fade_out():
	$AnimationPlayer.play("radar_fade_out")
	yield($AnimationPlayer, "animation_finished")
	$Radar.visible = false

func play_question_fade_in():
	$AnimationPlayer.play("question_fade_in")
	yield($AnimationPlayer, "animation_finished")
	$Question.visible = true

func play_question_fade_out():
	$AnimationPlayer.play("question_fade_out")
	yield($AnimationPlayer, "animation_finished")
	$Question.visible = false

func mode_switch():
	if not startup_finished:
		return
	match active_mode:
		Mode.RADAR:
			play_radar_fade_out()
			yield($AnimationPlayer, "animation_finished")
			play_question_fade_in()
			active_mode = Mode.QUESTION
		Mode.QUESTION:
			play_question_fade_out()
			yield($AnimationPlayer, "animation_finished")
			play_radar_fade_in()
			active_mode = Mode.RADAR

func _process(delta):
	if (Input.is_action_just_pressed("wui_left") or Input.is_action_just_pressed("wui_right")) and startup_finished:
		mode_switch()

func on_radar_button_pressed():
	emit_signal("radar_button_pressed")

func wui_fade_out():
	print("Fade-out started.")
	$AnimationPlayer.play("wui_fade_out")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("fade_out_completed")    

func _ready():
	$Radar.visible = false
	$Question.visible = false
	start_up()
	$Radar.connect("mouse_entered", self, "on_radar_mouse_entered")
	$Radar.connect("mouse_exited", self, "on_radar_mouse_exited")
	$Question.connect("mouse_entered", self, "on_question_mouse_entered")
	$Question.connect("mouse_exited", self, "on_question_mouse_exited")
	$Radar.connect("pressed", self, "on_radar_button_pressed")

func on_radar_mouse_entered():
	$Radar.modulate = Color(1, 1, 1, 1)

func on_radar_mouse_exited():
	$Radar.modulate = Color(1, 1, 1, 0.7)

func on_question_mouse_entered():
	$Question.modulate = Color(1, 1, 1, 1)

func on_question_mouse_exited():
	$Question.modulate = Color(1, 1, 1, 0.7)
