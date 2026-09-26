class_name EnemyDialogue extends Node
@export var dialogueFile : DialogueResource

func GetDialogue():
	return dialogueFile

@export var item : Item
@export var amount : int
@export var lootTable : LootTable

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
	return [item, amount]
