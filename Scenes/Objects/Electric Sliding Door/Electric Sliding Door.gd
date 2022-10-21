extends Node2D

const PLAYERNAME="Player"
onready var doorAnimation=$DoorSprite
onready var doorInteraction=$DoorArea
onready var doorCollision=$DoorCloseCollision/CollisionShape2D

func _ready():
	connect("process",self,"_process")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var bodies=doorInteraction.get_overlapping_bodies()
		for body in bodies:
			if body.get_name()==PLAYERNAME:
				doorAnimation.play("open") if ((doorAnimation.animation=="closed") or (doorAnimation.animation=="close")) else doorAnimation.play("close")
				doorCollision.disabled = not doorCollision.disabled
