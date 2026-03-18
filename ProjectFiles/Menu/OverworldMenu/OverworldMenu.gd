class_name OverworldMenu extends Sprite2D
signal close()
enum OverworldMenuState{Menu, EquipMenu, Inventory, Health, Settings}
var state : OverworldMenuState = OverworldMenuState.Menu

@export var mainButtons : Array[Sprite2D]
var mainButtonIndex : int
@export var mainButtonDeselectColor : Color

@export var equipMenuBG : Texture
@export var invMenuBG : Texture
@export var defaultMenuBG : Texture
@onready var player: Player = $"../../.."
@onready var player_inventory: PlayerInventory = $"../../../PlayerInventory"

var subStateLvl : int
var subStateIndex : Array[int] = [0,0,0]
func _ready() -> void:
	CloseMenu()
	pass

## Main Functions
func OpenMenu():
	show()
	state = OverworldMenuState.Menu
	mainButtonIndex = 0
	subStateLvl = 0
	for i in mainButtons:
		i.modulate = mainButtonDeselectColor
	mainButtons[mainButtonIndex].modulate = Color.WHITE
	DisplaySelectedMainButton()
	inv_menu_control.hide()
	DisplayEquipMenu()

func CloseMenu():
	hide()
	close.emit()

func GetInput(input : String):
	if state == OverworldMenuState.Menu:
		if input == "up" : MainButtonNav(-1)
		if input == "down" : MainButtonNav(1)
		if input == "return" : CloseMenu()
		if input == "select" : SelectMenu()
	elif state == OverworldMenuState.EquipMenu: EquipNav(input)
	elif state == OverworldMenuState.Inventory: InventoryNav(input)

## Menu Functions
func MainButtonNav(dir : int):
	mainButtons[mainButtonIndex].modulate = mainButtonDeselectColor
	mainButtonIndex += dir
	if mainButtonIndex >= mainButtons.size(): mainButtonIndex = 0
	if mainButtonIndex < 0: mainButtonIndex = mainButtons.size() - 1
	mainButtons[mainButtonIndex].modulate = Color.WHITE
	DisplaySelectedMainButton()

func DisplaySelectedMainButton():
	match mainButtonIndex:
		0:
			DisplayEquipMenu()
			inv_menu_control.hide()
		1:
			DisplayInventoryMenu()
			equip_menu_control.hide()
		_:
			texture = defaultMenuBG
			inv_menu_control.hide()
			equip_menu_control.hide()

func SelectMenu():
	subStateIndex = [0,0,0]
	match mainButtonIndex:
		0:
			state = OverworldMenuState.EquipMenu
			equipChoices[subStateIndex[subStateLvl]].SelectButton()
		1:
			state = OverworldMenuState.Inventory
			invHeaderButtons[subStateIndex[subStateLvl]].SelectButton()

## EquipMenu Functions
@onready var equip_menu_control: Control = $EquipMenuControl
@export var equipChoices: Array[SelectableText]
@export var equipSlots: Array[SelectableText_Equipment]
var equipSlotTags : Array[String] = ["Weapon", "Weapon", "Body", "Accessory", "Accessory", "Accessory"]
@onready var healthSlider: HealthSlider = $EquipMenuControl/HealthSlider
@onready var bloodSlider: HealthSlider = $EquipMenuControl/BloodSlider
@onready var equippableItemContainer: VBoxContainer = $EquipMenuControl/VBoxContainer3
@export var statTextUI: Array[RichTextLabel]

func DisplayEquipMenu():
	texture = equipMenuBG
	equip_menu_control.show()
	for i in equipChoices:
		i.DeselectButton()
	for i in equipSlots:
		i.DeselectButton()
	UpdateStatsText()
	ClearInventoryUI([equippableItemContainer])

func UpdateStatsText():
	healthSlider.IntialiseSlider(player.GetMaxHealth(), player.GetCurrentHealth())
	bloodSlider.IntialiseSlider(player.GetMaxBlood(), player.GetBloodLevel())
	statTextUI[0].text = "[font_size=16]STR\n[font_size=30]%d" % [player.GetStat(0)]
	statTextUI[1].text = "[font_size=16]DEX\n[font_size=30]%d" % [player.GetStat(1)]
	statTextUI[2].text = "[font_size=16]KNW\n[font_size=30]%d" % [player.GetStat(2)]
	statTextUI[3].text = "[font_size=16]PER\n[font_size=30]%d" % [player.GetStat(3)]

func EquipNav(input : String):
	match subStateLvl:
		0:
			match input:
				"up": NavigateMenu(-1, equipChoices)
				"down": NavigateMenu(1, equipChoices)
				"return": 
					equipChoices[subStateIndex[subStateLvl]].DeselectButton()
					state = OverworldMenuState.Menu
				"select": 
					if subStateIndex[subStateLvl] != 2:
						subStateLvl = 1
						equipSlots[subStateIndex[subStateLvl]].SelectButton()
		1:
			match input:
				"up": NavigateMenu(-1, equipSlots)
				"down": NavigateMenu(1, equipSlots)
				"return": 
					equipSlots[subStateIndex[subStateLvl]].DeselectButton()
					subStateLvl = 0
				"select": 
					PopulateInventoryUI([equippableItemContainer], 3, true, 16, equipSlotTags[subStateIndex[subStateLvl]], subStateIndex[subStateLvl] != 1)
					subStateLvl = 2
					if subStateIndex[subStateLvl] < invObjects.size():
						invObjects[subStateIndex[subStateLvl]].SelectButton()
					else:
						subStateIndex[subStateLvl] = 0
						invObjects[subStateIndex[subStateLvl]].SelectButton()
		2:
			match input:
				"up": NavigateMenu(-1, invObjects)
				"down": NavigateMenu(1, invObjects)
				"return": 
					invObjects[subStateIndex[subStateLvl]].DeselectButton()
					subStateLvl = 1
					ClearInventoryUI([equippableItemContainer])
				"select":
					AddEquipment()

func AddEquipment():
	if player_inventory.GetEquippedItems(subStateIndex[1]) != null:
		player_inventory.AddItem(player_inventory.GetEquippedItems(subStateIndex[1]), 1)
	player_inventory.SetEquippedItem(subStateIndex[1], invObjects[subStateIndex[subStateLvl]].item)
	equipSlots[subStateIndex[1]].SetEquippedItem(invObjects[subStateIndex[subStateLvl]].item)
	player_inventory.RemoveItem(invObjects[subStateIndex[subStateLvl]].item)
	subStateLvl = 1
	player.SetAdjustedStatComponent()
	UpdateStatsText()
	ClearInventoryUI([equippableItemContainer])

## InventoryMenu Functions
@onready var inv_menu_control: Control = $InvMenuControl
var showableInvItems : Dictionary[Item, int]
var invObjects : Array[Item_Button]
@onready var invItemDescription: RichTextLabel = $InvMenuControl/ItemDescription
@export var invHeaderButtons : Array[SelectableText]
var invHeaderTags : Array[String] = ["", "Healing", "Equipment", "Weapon", "Book"]
@export var item_button_scene : PackedScene
@export var left_list : VBoxContainer
@export var right_list : VBoxContainer

func DisplayInventoryMenu():
	texture = invMenuBG
	inv_menu_control.show()
	for i in invHeaderButtons:
		i.DeselectButton()
	PopulateInventoryUI([left_list,right_list], 20, false, 24, invHeaderTags[subStateIndex[subStateLvl]])

func InventoryNav(input : String):
	match subStateLvl:
		0:
			match input:
				"left": 
					NavigateMenu(-1, invHeaderButtons)
					PopulateInventoryUI([left_list,right_list], 20, false, 24, invHeaderTags[subStateIndex[subStateLvl]])
				"right": 
					NavigateMenu(1, invHeaderButtons)
					PopulateInventoryUI([left_list,right_list], 20, false, 24, invHeaderTags[subStateIndex[subStateLvl]])
				"return": 
					invHeaderButtons[subStateIndex[subStateLvl]].DeselectButton()
					state = OverworldMenuState.Menu
				"select": 
					if player_inventory.items.size() > 0 && invObjects.size() > 0:
						subStateLvl = 1
						invObjects[subStateIndex[subStateLvl]].SelectButton()
						invItemDescription.text = invObjects[subStateIndex[subStateLvl]].item.description
		1:
			match input:
				"up": NavigateMenu(-2, invObjects)
				"down": NavigateMenu(2, invObjects)
				"left": NavigateMenu(-1, invObjects)
				"right": NavigateMenu(1, invObjects)
				"return": 
					if invObjects.size() > 0:
						invObjects[subStateIndex[subStateLvl]].DeselectButton()
					subStateLvl = 0

func PopulateInventoryUI(invContainer : Array[VBoxContainer], maxItems : int, includeNull : bool, fontSize : int, tag : String, includeTwoHanded : bool = true):
	ClearInventoryUI(invContainer)
	
	var shown := 0
	var index := 0
	
	if includeNull:
		var nullBtn : Item_Button = item_button_scene.instantiate()
		invContainer[0].add_child(nullBtn)
		nullBtn.Setup(null, 0, fontSize)
		invObjects.append(nullBtn)
	
	for item in player_inventory.GetItems():
		if shown >= maxItems:
			break
		if tag == "" || item.HasTag(tag):
			if item is Item_Weapon && !includeTwoHanded:
				var weapon = item as Item_Weapon
				if weapon.twoHanded:
					continue
			var qty : int = player_inventory.items[item]
			# Instance the ItemButton scene
			var btn : Item_Button = item_button_scene.instantiate()
			# Place alternating between two lists
			invContainer[index % invContainer.size()].add_child(btn)
			# SET DATA ON THE BUTTON
			btn.Setup(item, qty, fontSize)
			invObjects.append(btn)
			index += 1
			shown += 1

func ClearInventoryUI(invContainer : Array[VBoxContainer]):
	for contain in invContainer:
		for child in contain.get_children():
			child.queue_free()
	invObjects.clear()

func NavigateMenu(dir : int, arr : Array):
	if arr.size() > 0:
		arr[subStateIndex[subStateLvl]].DeselectButton()
		subStateIndex[subStateLvl] += dir
		if subStateIndex[subStateLvl] >= arr.size(): subStateIndex[subStateLvl] = 0
		if subStateIndex[subStateLvl] < 0 : subStateIndex[subStateLvl] = arr.size() -1
		arr[subStateIndex[subStateLvl]].SelectButton()
		#invItemDescription.text = itemButtons[selectedInvIndex].item.description
