extends VisibilityNotifier2D

onready var visibilitynotifier=$VisibilityNotifier2D
onready var pcamera=$YSort/Player/Camera2D

func _on_visibilitynotifier_camera_entered(pcamera):
	visible=true

func _on_visibilitynotifier_camera_exited(pcamera):
	visible=false

