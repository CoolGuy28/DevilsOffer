class_name OM_EquipmentPanel extends OM_Base
@export var equipChoices: Array[SelectableText]
@export var equipSlots: Array[SelectableText_Equipment]

var equipSlotTags : Array[Global.ItemTags] = [
Global.ItemTags.Weapon,
Global.ItemTags.Weapon,
Global.ItemTags.Body,
Global.ItemTags.Accessory,
Global.ItemTags.Accessory,
Global.ItemTags.Accessory]

@onready var healthSlider: HealthSlider = $EquipMenuControl/HealthSlider
@onready var bloodSlider: HealthSlider = $EquipMenuControl/BloodSlider
@onready var equippableItemContainer: VBoxContainer = $EquipMenuControl/VBoxContainer3

@export var statTextUI: Array[RichTextLabel]
@export var acDisp : RichTextLabel
@export var mcDisp : RichTextLabel
@export var bnsDisp : RichTextLabel

var invObjects : Array[Item_Button] = []
var item_button_scene = preload("uid://dyoane104rjpn")

enum CurrentState { None, Header, Equipment, Inv}
var state : CurrentState = CurrentState.None
var headerState : int = 0
var slotState : int = 0
var itemState : int = 0

func DisplayMenu():
	visible = true
	for i in equipChoices:
		i.DeselectButton()
	var a : int = 0
	for i in equipSlots:
		i.SetEquippedItem(overworld_menu.GetPlayerInv().GetEquippedItem(a))
		i.DeselectButton()
		a += 1
	overworld_menu.GetPlayer().SetAdjustedStatComponent()
	UpdateMenu()
	ClearInventoryUI([equippableItemContainer])

func SetDefaultState(): 
	state = CurrentState.Header
	equipChoices[headerState].SelectButton()

func SetNoneState():
	state = CurrentState.None

func UpdateMenu():
	healthSlider.IntialiseSlider(overworld_menu.GetPlayer().GetMaxHealth(), overworld_menu.GetPlayer().GetCurrentHealth())
	bloodSlider.IntialiseSlider(overworld_menu.GetPlayer().GetMaxBlood(), overworld_menu.GetPlayer().GetBloodLevel())

	statTextUI[0].text = "[font_size=16]STR\n[font_size=30]%d" % overworld_menu.GetPlayer().GetStat(0)
	statTextUI[1].text = "[font_size=16]DEX\n[font_size=30]%d" % overworld_menu.GetPlayer().GetStat(1)
	statTextUI[2].text = "[font_size=16]KNW\n[font_size=30]%d" % overworld_menu.GetPlayer().GetStat(2)
	statTextUI[3].text = "[font_size=16]PER\n[font_size=30]%d" % overworld_menu.GetPlayer().GetStat(3)
	
	acDisp.text = "[font_size=16]AC\n[font_size=20]%d" % overworld_menu.GetPlayer().GetAC()
	mcDisp.text = "[font_size=16]MC\n[font_size=20]%d" % overworld_menu.GetPlayer().GetMC()
	bnsDisp.text = "[font_size=20]%d" % overworld_menu.GetPlayer().GetStateBonus()

func InputNav(input : String):
	match state:
		CurrentState.Header: #Add, Optimize, Clear
			match input:
				"up": 
					GameManager.PlayMenuSFX("Hover")
					headerState = NavigateMenu(-1, equipChoices, headerState)
				"down": 
					GameManager.PlayMenuSFX("Hover")
					headerState = NavigateMenu(1, equipChoices, headerState)
				"return":
					GameManager.PlayMenuSFX("Cancel")
					equipChoices[headerState].DeselectButton()
					overworld_menu.SetInMenu(false)
				"select":
					GameManager.PlayMenuSFX("Select")
					if headerState == 0:
						state = CurrentState.Equipment
						equipSlots[slotState].SelectButton()
					elif headerState == 1:
						OptimizeEquipment()
					elif headerState == 2:
						ClearEquipment()
		CurrentState.Equipment: #Select Body Slots
			match input:
				"up": 
					GameManager.PlayMenuSFX("Hover")
					slotState = NavigateMenu(-1, equipSlots, slotState)
				"down": 
					GameManager.PlayMenuSFX("Hover")
					slotState = NavigateMenu(1, equipSlots, slotState)
				"return":
					GameManager.PlayMenuSFX("Cancel")
					equipSlots[slotState].DeselectButton()
					state = CurrentState.Header
				"select":
					GameManager.PlayMenuSFX("Select")
					var allowTwoHanded : bool = true
					if slotState == 0: 
						if overworld_menu.GetPlayerBody().GetArmCount() <= 0: return
						elif overworld_menu.GetPlayerBody().GetArmCount() == 1 : allowTwoHanded = false
					elif slotState == 1 : 
						if overworld_menu.GetPlayerBody().GetArmCount() <= 1: return
						else: allowTwoHanded = false
					state = CurrentState.Inv
					itemState = 0
					PopulateEquipmentUI([equippableItemContainer], 16, true, 16, [equipSlotTags[slotState]], allowTwoHanded)
					if invObjects.size() > 0:
						invObjects[0].SelectButton()
		CurrentState.Inv:#EquippableItems
			match input:
				"up": 
					GameManager.PlayMenuSFX("Hover")
					itemState = NavigateMenu(-1, invObjects, itemState)
				"down": 
					GameManager.PlayMenuSFX("Hover")
					itemState = NavigateMenu(1, invObjects, itemState)
				"return":
					GameManager.PlayMenuSFX("Cancel")
					if invObjects.size() > 0:
						invObjects[itemState].DeselectButton()
					state = CurrentState.Equipment
					ClearInventoryUI([equippableItemContainer])
				"select":
					GameManager.PlayMenuSFX("Select")
					AddEquipment()

func AddEquipment():
	if invObjects.size() == 0:
		return
	var item = invObjects[itemState].item
	SetItemInSlot(slotState, item)
	state = CurrentState.Equipment
	overworld_menu.GetPlayer().SetAdjustedStatComponent()
	UpdateMenu()
	ClearInventoryUI([equippableItemContainer])

func SetItemInSlot(slot : int, item : Item):
	if overworld_menu.GetPlayerInv().GetEquippedItem(slot) != null:
		overworld_menu.GetPlayerInv().AddItem(overworld_menu.GetPlayerInv().GetEquippedItem(slot), 1)
	overworld_menu.GetPlayerInv().SetEquippedItem(slot, item)
	equipSlots[slot].SetEquippedItem(item)
	overworld_menu.GetPlayerInv().RemoveItem(item)

func OptimizeEquipment():
	for slot in range(6):
		var bestEquippable : Item_Equippable = null
		if slot == 0:
			if overworld_menu.GetPlayerBody().GetArmCount() <= 0: continue
			for i in overworld_menu.GetPlayerInv().GetUnequippedWeapons(overworld_menu.GetPlayerBody().GetArmCount() == 1):
				if i is not Item_Weapon: continue
				if bestEquippable == null || i.GetEquippableValue() > bestEquippable.GetEquippableValue():
					bestEquippable = i
		elif slot == 1:
			if overworld_menu.GetPlayerBody().GetArmCount() != 2: continue
			for i in overworld_menu.GetPlayerInv().GetUnequippedWeapons(true):
				if bestEquippable == null || i.GetEquippableValue() > bestEquippable.GetEquippableValue():
					bestEquippable = i
		elif slot == 2:
			for i in overworld_menu.GetPlayerInv().GetItemsTagged(Global.ItemTags.Body):
				if bestEquippable == null || i.GetEquippableValue() > bestEquippable.GetEquippableValue():
					bestEquippable = i
		else:
			for i in overworld_menu.GetPlayerInv().GetItemsTagged(Global.ItemTags.Accessory):
				if bestEquippable == null || i.GetEquippableValue() > bestEquippable.GetEquippableValue():
					bestEquippable = i
		if bestEquippable != null:
			SetItemInSlot(slot, bestEquippable)
	overworld_menu.GetPlayer().SetAdjustedStatComponent()
	UpdateMenu()

func ClearEquipment():
	for slot in range(6):
		if overworld_menu.GetPlayerInv().GetEquippedItem(slot) != null:
			overworld_menu.GetPlayerInv().AddItem(overworld_menu.GetPlayerInv().GetEquippedItem(slot), 1)
		overworld_menu.GetPlayerInv().SetEquippedItem(slot, null)
		equipSlots[slot].SetEquippedItem(null)
		overworld_menu.GetPlayer().SetAdjustedStatComponent()
		UpdateMenu()


func PopulateEquipmentUI(invContainer, maxItems, includeNull, fontSize, tags : Array[Global.ItemTags], TwoHanded : bool = true):
	invObjects.clear()
	ClearInventoryUI(invContainer)

	var shown := 0
	var index := 0

	if includeNull:
		var nullBtn = item_button_scene.instantiate()
		invContainer[0].add_child(nullBtn)
		nullBtn.Setup(null, 0, fontSize)
		invObjects.append(nullBtn)
		
	var itemsList
	if TwoHanded == false:
		itemsList = overworld_menu.GetPlayerInv().GetUnequippedWeapons(true)
	elif tags.is_empty() : itemsList = overworld_menu.GetPlayerInv().GetItems()
	else:
		for tag in tags:
			itemsList = overworld_menu.GetPlayerInv().GetItemsTagged(tag)
	for item in itemsList:
		if shown >= maxItems:
			break

		var btn = item_button_scene.instantiate()
		invContainer[index % invContainer.size()].add_child(btn)
		btn.Setup(item, overworld_menu.GetPlayerInv().items[item], fontSize)
		invObjects.append(btn)
		index += 1
		shown += 1
