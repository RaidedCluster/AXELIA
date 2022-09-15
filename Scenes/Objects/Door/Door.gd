extends Node2D

onready var doorAnimation=$DoorSprite
onready var doorInteraction=$DoorArea
onready var doorCollision=$DoorCloseCollision/CollisionShape2D

func _ready():
	connect("body_entered",self,"_on_body_enter")
	connect("process",self,"_process")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var areas=doorInteraction.get_overlapping_areas()
		for area in areas:
			if area.get_name()=="Interaction Area":
					doorAnimation.play("open") if ((doorAnimation.animation=="closed") or (doorAnimation.animation=="close")) else doorAnimation.play("close")
					doorCollision.disabled = not doorCollision.disabled
func _on_body_enter(body):
	print(body.get_name()+" has entered the area.")
