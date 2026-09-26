class_name PlayerInventory extends Node
@export var equippedWeapons : Array[Item_Weapon]
@export var equippedAccessory : Array[Item_Equippable]
@export var inventoryStats : StatComponent_Player
@export var items : Dictionary[Item, int]

func save_to_dict(s: SaveKitSerializer) -> Dictionary:
	return {
	"items": s.encode_var(items),
	"weapons" : s.encode_var(equippedWeapons),
	"accessories" : s.encode_var(equippedAccessory)
	}

func load_from_dict(s: SaveKitDeserializer, data: Dictionary) -> void:
	var itemD = s.decode_var(data["items"], TYPE_DICTIONARY)
	if itemD != null:  items.merge(itemD)
	var ew = s.decode_var(data["weapons"], TYPE_ARRAY)
	equippedWeapons.clear()
	equippedWeapons.append_array(ew)
	var ea = s.decode_var(data["accessories"], TYPE_ARRAY)
	equippedAccessory.clear()
	equippedAccessory.append_array(ea)

func GetItems() -> Dictionary[Item, int]:
	return items

func GetItemsTagged(tag : Global.ItemTags) -> Array[Item]:
	var returnItems : Array[Item]
	for i in GetItems():
		if i.HasTag(tag): returnItems.append(i)
	return returnItems

func GetUnequippedWeapons(lightOnly : bool = false) -> Array[Item_Weapon]:
	var weapons : Array[Item_Weapon]
	for i in GetItemsTagged(Global.ItemTags.Weapon):
		if i is Item_Weapon:
			if lightOnly && i.weaponType == 2:
				continue
			weapons.append(i)
	return weapons

func GetItem(i : String):
	for item in items:
		if item.itemName == i:
			return item
	return null

func HasItem(s : String, a : int = 1):
	for item in items:
		if item.itemName == s && items[item] >= a:
			return true
	return false

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
			return true #EndStack
	return false

func RemoveItemName(i : String):
	for item in items:
		if item.itemName == i:
			return RemoveItem(item)

func SetInventoryStats():
	inventoryStats.SetZero()
	for w in equippedWeapons:
		if w != null:
			inventoryStats.AddStatComponent(w.equippedStats)
	for i in equippedAccessory:
		if i != null:
			inventoryStats.AddStatComponent(i.equippedStats)
	return inventoryStats

func GetMainHand() -> Item_Weapon:
	return equippedWeapons[0]

func GetOffHand() -> Item_Weapon:
	return equippedWeapons[1]

func UnequipWeapon(index : int):
	AddItem(equippedWeapons[index], 1)
	equippedWeapons[index] = null

func GetWeapon(index : int) -> Item_Weapon:
	return equippedWeapons[index]

func GetEquippedAccessory(index : int) -> Item_Equippable:
	return equippedAccessory[index]

func GetEquippedAccessories() -> Array[Item_Equippable]:
	var returnArray : Array[Item_Equippable]
	for i in equippedAccessory: 
		if i != null && i is Item_Equippable:
			returnArray.append(i)
	return returnArray

func HasEquippedAccessory(s : String):
	for i in GetEquippedAccessories():
		if i.itemName == s:
			return true
	return false

func GetEquippedItem(index : int) -> Item_Equippable:
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

func GetNutritionAmount():
	var amount : int = 0
	for i in GetItems():
		if i is Item_Food:
			amount += i.GetNutrition()
	return amount

func RemoveNutrition(amount : int):
	var a : int = amount
	for i in GetItems():
		if i is Item_Food:
			a -= i.GetNutrition()
			RemoveItem(i)
			if a <= 0:
				return
