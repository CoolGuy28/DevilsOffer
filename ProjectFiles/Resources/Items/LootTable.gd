class_name LootTable extends Resource
@export var items : Array[ItemTableSlot]

func GetLoot():
	var randItem : ItemTableSlot
	if items.size() <= 0 : randItem = null
	else : randItem = items[randi()%items.size()]
	if !randItem.multiple && randItem.singleItem == null || !randItem.multiple && randItem.singleQuant <= 0 : randItem = null
	if randItem.multiple && randItem.multipleItems.is_empty() : randItem = null
	return randItem
