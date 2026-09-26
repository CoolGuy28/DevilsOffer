class_name Interactable_WorldItem extends Interactable
@export var item : Item

func _ready() -> void:
	super()
	if interacted : DisableInteractable()

func Interact(_player):
	super(_player)
	if item != null:
		_player.player_inventory.AddItem(item, 1)
	await DialogueManager.dialogue_ended
	interacted = true
	disabled = true
	DisableInteractable()

func EnableInteractable():
	if interacted : return
	super()
