class_name Item_Usable extends Item
@export var action : Action
@export var OOCAction : Action_Utility
@export var OOCUseBodyMenu : bool
@export var bonusAction : bool
@export var reusable : bool

func OnUse(player : Player):
	if !reusable:
		player.player_inventory.RemoveItem(self)

func OnUseOOC(player : Player, target : Array[PlayerBodyPart] = []):
	var _result = await OOCAction.DoAction(player, target)
	if !reusable:
		return player.player_inventory.RemoveItem(self)

func CanUse(_player : Player):
	if action != null : return true
	else : return null

func CanUseOOC(_player : Player):
	if OOCAction != null : return true
	else : return false
