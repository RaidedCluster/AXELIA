extends VisibilityNotifier2D

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("screen_entered", self, "_on_screen_entered")
	connect("screen_exited", self, "_on_screen_exited")

func _on_screen_entered():
	if owner is Node2D:
		owner.visible = true  # Make the parent object visible

func _on_screen_exited():
	if owner is Node2D:
		owner.visible = false  # Make the parent object invisible
