extends StaticBody2D

const PLAYERNAME = "Player"
const NPCNAME = "Kinesys Sentinel"
onready var doorSprite = $DoorSprite
onready var doorInteraction = $DoorArea
onready var npcTriggerArea = $NPCOpenArea
onready var doorCloseCollision = $DoorCloseCollision/Close
onready var doorOpenCollision = $DoorCloseCollision/Open
onready var doorCloseOcclusion = $DynamicOcclusion

var door_is_open = false
var npc_in_area = false  # Flag to indicate if the NPC is within the trigger area

func _ready():
	npcTriggerArea.connect("body_entered", self, "_on_NPCOpenArea_body_entered")
	npcTriggerArea.connect("body_exited", self, "_on_NPCOpenArea_body_exited")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		handle_door_interaction()

func handle_door_interaction():
	var areas = doorInteraction.get_overlapping_areas()
	for area in areas:
		if area.name == "Interaction Area":
			toggle_door()

func toggle_door():
	if not door_is_open:
		doorSprite.play("open")
		door_is_open = true
		yield(get_tree().create_timer(doorSprite.frames.get_frame_count("open") / doorSprite.frames.get_animation_speed("open")), "timeout")
		doorCloseCollision.disabled = true
		doorOpenCollision.disabled = false
		doorCloseOcclusion.disabled = true
	else:
		doorSprite.play("close")
		door_is_open = false
		yield(get_tree().create_timer(doorSprite.frames.get_frame_count("close") / doorSprite.frames.get_animation_speed("close")), "timeout")
		doorCloseCollision.disabled = false
		doorOpenCollision.disabled = true
		doorCloseOcclusion.disabled = false
		if npc_in_area:
			_on_NPCOpenArea_body_entered()

func _on_NPCOpenArea_body_entered(body = null):
	if not body or body.name == NPCNAME:
		npc_in_area = true
		if not door_is_open:
			doorSprite.play("open")
			door_is_open = true
			yield(get_tree().create_timer(doorSprite.frames.get_frame_count("open") / doorSprite.frames.get_animation_speed("open")), "timeout")
			doorCloseCollision.disabled = true
			doorOpenCollision.disabled = false
			doorCloseOcclusion.disabled = true

func _on_NPCOpenArea_body_exited(body):
	if body.name == NPCNAME:
		npc_in_area = false

