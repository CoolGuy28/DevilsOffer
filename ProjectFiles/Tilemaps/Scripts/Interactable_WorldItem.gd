class_name Interactable_WorldItem extends Interactable
@export var item : Item

func Interact(_player):
	if interacted == false:
		interacted = true
		if item != null:
			_player.player_inventory.AddItem(item, 1)
		queue_free()
		return interactText
