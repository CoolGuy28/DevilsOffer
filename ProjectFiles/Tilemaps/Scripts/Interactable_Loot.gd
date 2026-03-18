class_name Interactable_Loot extends Interactable
@export_multiline var lootedText : Array[String] = ["You looted here already"]
@export var lootTable : LootTable
@export var lock : Lock

func Interact(_player):
	if lock != null:
		lock.player = _player
		_player.OpenSkillCheck(lock.pickLockDC, 0, lock)
	if interacted == false and lock == null:
		return OpenLoot(_player)
	#elif lock != null:
	#	return "The lock remains"
	elif interacted == true:
		return lootedText

func OpenLoot(_player):
	interacted = true
	if changeSpriteOnInteract != 0:
		sprite_2d.frame = changeSpriteOnInteract
	var text = interactText.duplicate()
	text.append(AddLoot(_player))
	return text

func AddLoot(_player) -> String:
	if lootTable != null:
		var randItem = lootTable.GetLoot()
		if randItem != null and !randItem.multiple:
			_player.player_inventory.AddItem(randItem.singleItem, randItem.singleQuant)
			return "You find [color=red]" + str(randItem.singleQuant) + " " + randItem.singleItem.itemName + "[/color]!"
		else:
			return "You find nothing"
	else:
		return "It seems empty"
