class_name LootTable extends Resource
@export var no_item_chance : int = 5
@export var common_items : Dictionary[Item, ItemTableSlot]
@export var common_item_chance : int = 75
@export var rare_items : Dictionary[Item, ItemTableSlot]
@export var rare_item_chance : int = 20

func GetLoot():
	var r = randi() % (no_item_chance + common_item_chance + rare_item_chance)
	if !rare_items.is_empty() && rare_item_chance > 0 && r >= no_item_chance + common_item_chance:
		var random_key = rare_items.keys().pick_random()
		var slot : ItemTableSlot = rare_items[random_key]
		var amount : int = slot.amount + randi_range(-slot.randVariance, slot.randVariance)
		return [random_key, amount]
	elif !common_items.is_empty() && common_item_chance > 0 && r >= no_item_chance:
		var random_key = common_items.keys().pick_random()
		var slot : ItemTableSlot = common_items[random_key]
		var amount : int = slot.amount + randi_range(-slot.randVariance, slot.randVariance)
		return [random_key, amount]
	else : return null
