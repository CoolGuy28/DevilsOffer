class_name Item_Usable extends Item
@export var action : Action
@export var bonusAction : bool
@export var reusable : bool

func OnUse(player : Player):
	if !reusable:
		player.player_inventory.RemoveItem(self)

func CanUse(_player : Player):
	return true
