extends AnimatedSprite

const PLAYERNAME="Player"
onready var cameraRange=$Area2D

func _ready():
	connect("body_entered",self,"_on_body_enter")
	connect("process",self,"_process")
	
func _process(delta):
	var bodies=cameraRange.get_overlapping_bodies()
	for body in bodies:
			if body.get_name()==PLAYERNAME:
				print("Caught")

func _on_body_enter(body):
	print(body.get_name()+" has entered the area.")
