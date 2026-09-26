class_name Interactable_Door extends Interactable
@export var lock : Lock
@export var unlocked : bool

func _ready() -> void:
	super()

func Interact(_player):
	InteractionEnded.emit()
	if lock != null && !unlocked:
		super(_player)
	else:
		if interacted == false:
			OpenDoor()
		elif interacted == true:
			CloseDoor()

func OpenDoor():
	interacted = true
	set_collision_layer_value(5, false)
	ChangeSpriteFrame(1)
	PlaySFX("Open")
	InteractionEnded.emit()

func CloseDoor():
	interacted = false
	set_collision_layer_value(5, true)
	ChangeSpriteFrame(0)
	PlaySFX("Close")
	InteractionEnded.emit()
