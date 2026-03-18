class_name PlayerInventory extends Node
@export var equippedWeapons : Array[Item_Weapon]
@export var equippedAccessory : Array[Item_Equippable]
@export var inventoryStats : StatComponent_Player
@export var items : Dictionary[Item, int]

func GetItems() -> Dictionary[Item, int]:
	return items

func AddItem(item : Item, amount : int):
	if items.has(item):
		items[item] += amount
	else:
		items[item] = amount

func RemoveItem(item : Item):
	if items.has(item):
		items[item] -= 1
		if items[item] <= 0:
			items.erase(item)

func SetInventoryStats():
	inventoryStats.SetZero()
	for w in equippedWeapons:
		if w != null:
			inventoryStats.AddStatComponent(w.equippedStats)
	for i in equippedAccessory:
		if i != null:
			inventoryStats.AddStatComponent(i.equippedStats)

func GetMainHand() -> Item_Weapon:
	return equippedWeapons[0]

func GetWeapon(index : int) -> Item_Weapon:
	return equippedWeapons[index]

func GetEquippedAccessory(index : int) -> Item_Equippable:
	return equippedAccessory[index]

func GetEquippedItems(index : int) -> Item_Equippable:
	if index <= 1:
		return equippedWeapons[index]
	else:
		return equippedAccessory[index - 2]

func SetEquippedItem(index : int, item : Item_Equippable):
	if index <= 1:
		equippedWeapons[index] = item
	else:
		equippedAccessory[index - 2] = item
	SetInventoryStats()

func GetUsableItems() -> Dictionary[Item, int]:
	var a : Dictionary[Item, int]
	for i in items:
		if i is Item_Usable:
			a[i] = items.get(i)
	return a
