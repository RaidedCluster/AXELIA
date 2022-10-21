extends AnimatedSprite

const PLAYERNAME="Player"
onready var cameraRange=$Area2D

func _ready():
	connect("process",self,"_process")
	
func _process(delta):
	var bodies=cameraRange.get_overlapping_bodies()
	for body in bodies:
			if body.get_name()==PLAYERNAME:
				print("Caught")
