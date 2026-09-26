class_name Interactable_Loot extends Interactable
@export var item : Item
@export var amount : int
@export var lootTable : LootTable
@export var lock : Lock
@export var unlocked : bool

func GetLoot():
	if lootTable != null:
		var randItem = lootTable.GetLoot()
		if randItem != null:
			item = randItem[0]
			amount = randItem[1]
			#print(item.itemName + str(amount))
		else:
			item = null
			amount = 0
