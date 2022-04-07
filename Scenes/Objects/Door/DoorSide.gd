extends Node2D

const PLAYERNAME="Player"
onready var doorAnimation=$DoorSprite
onready var doorInteraction=$DoorArea
onready var doorCloseCollision=$DoorCloseCollision/Close
onready var doorOpenCollision=$DoorCloseCollision/Open

func _ready():
	connect("body_entered",self,"_on_body_enter")
	connect("process",self,"_process")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var bodies=doorInteraction.get_overlapping_bodies()
		for body in bodies:
			if body.get_name()==PLAYERNAME:
				doorAnimation.play("open") if ((doorAnimation.animation=="closed") or (doorAnimation.animation=="close")) else doorAnimation.play("close")
				doorCloseCollision.disabled = not doorCloseCollision.disabled
				doorOpenCollision.disabled = not doorOpenCollision.disabled
func _on_body_enter(body):
	print(body.get_name()+" has entered the area.")
