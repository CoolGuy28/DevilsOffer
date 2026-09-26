class_name OM_InventoryPanel extends OM_Base

var invObjects : Array[Item_Button] = []
@onready var invItemDescription: RichTextLabel = $InvMenuControl/ItemDescription
@export var invHeaderButtons : Array[SelectableText]
var item_button_scene = preload("uid://dyoane104rjpn")
@export var left_list : VBoxContainer
@export var right_list : VBoxContainer
@export var useItem : Item
@export var itemPanel : OM_Base
@onready var body_panel: OM_BodyPanel = $"../BodyPanel"
@onready var equipment_panel: OM_EquipmentPanel = $"../EquipmentPanel"
var navBodyPanel : bool

enum CurrentState { None, Header, Inv, UseItem}
var state : CurrentState = CurrentState.None
var headerState : int = 0
var itemState : int = 0

func DisplayMenu():
	visible = true
	for i in invHeaderButtons:
		i.DeselectButton()
	PopulateInventoryUI([left_list,right_list], 20, false, 24, GetHeaderItemTags(0))
	navBodyPanel = false

func GetHeaderItemTags(index : int) -> Array[Global.ItemTags]:
	match index:
		1 :  return [Global.ItemTags.Healing]
		2 :  return [Global.ItemTags.Body, Global.ItemTags.Accessory]
		3 :  return [Global.ItemTags.Weapon]
		4 :  return [Global.ItemTags.Book, Global.ItemTags.Scroll]
		0, _ :  return []

func SetDefaultState(): 
	state = CurrentState.Header
	invHeaderButtons[headerState].SelectButton()

func SetNoneState():
	state = CurrentState.None

func InputNav(input : String):
	match state:
		CurrentState.Header:
			match input:
				"left":
					GameManager.PlayMenuSFX("Hover")
					headerState = NavigateMenu(-1, invHeaderButtons, headerState)
					PopulateInventoryUI([left_list,right_list], 20, false, 24, GetHeaderItemTags(headerState))
				"right":
					GameManager.PlayMenuSFX("Hover")
					headerState = NavigateMenu(1, invHeaderButtons, headerState)
					PopulateInventoryUI([left_list,right_list], 20, false, 24, GetHeaderItemTags(headerState))
				"return":
					GameManager.PlayMenuSFX("Cancel")
					invHeaderButtons[headerState].DeselectButton()
					overworld_menu.SetInMenu(false)
				"select":
					GameManager.PlayMenuSFX("Select")
					UpdateMenu()
		CurrentState.Inv:
			match input:
				"up": 
					GameManager.PlayMenuSFX("Hover")
					itemState = NavigateMenu(-2, invObjects, itemState)
					UpdateMenu()
				"down": 
					GameManager.PlayMenuSFX("Hover")
					itemState = NavigateMenu(2, invObjects, itemState)
					UpdateMenu()
				"left": 
					GameManager.PlayMenuSFX("Hover")
					itemState = NavigateMenu(-1, invObjects, itemState)
					UpdateMenu()
				"right": 
					GameManager.PlayMenuSFX("Hover")
					itemState = NavigateMenu(1, invObjects, itemState)
					UpdateMenu()
				"return":
					GameManager.PlayMenuSFX("Cancel")
					if invObjects.size() > 0:
						invObjects[itemState].DeselectButton()
					state = CurrentState.Header
				"select":
					if invObjects[itemState].item is not Item_Usable : return
					if invObjects[itemState].item.CanUseOOC(overworld_menu.GetPlayer()):
						GameManager.PlayMenuSFX("Select")
						useItem = invObjects[itemState].item
						state = CurrentState.UseItem
						if useItem.OOCUseBodyMenu:
							itemPanel = body_panel
							var f = useItem.OOCAction.focus
							navBodyPanel = false
							match f:
								"All":
									body_panel.SelectAllLimbs(true)
									body_panel.SelectAllOrgans(true)
								"Organs":
									body_panel.SelectAllOrgans(true)
								"Limbs":
									body_panel.SelectAllLimbs(true)
								"Head":
									body_panel.SelectLimb()
								"Limb":
									body_panel.SelectLimb()
									navBodyPanel = true
								"Organ":
									body_panel.SelectOrgan()
									navBodyPanel = true
						else:
							itemPanel = equipment_panel
						itemPanel.SetNoneState()
						itemPanel.DisplayMenu()
		CurrentState.UseItem:
			match input:
				"up": 
					if !navBodyPanel : return
					GameManager.PlayMenuSFX("Hover")
					body_panel.NavigateBody(2)
				"down": 
					if !navBodyPanel : return
					GameManager.PlayMenuSFX("Hover")
					body_panel.NavigateBody(-2)
				"left": 
					if !navBodyPanel : return
					GameManager.PlayMenuSFX("Hover")
					body_panel.NavigateBody(-1)
				"right": 
					if !navBodyPanel : return
					GameManager.PlayMenuSFX("Hover")
					body_panel.NavigateBody(1)
				"return":
					GameManager.PlayMenuSFX("Cancel")
					CloseUseItems()
				"select":
					if useItem != null:
						GameManager.PlayMenuSFX("Select")
						var f = useItem.OOCAction.focus
						var t : Array[PlayerBodyPart] = []
						match f:
							"All":
								t = overworld_menu.GetPlayerBody().GetBodyPart("All")
							"Organs":
								t = overworld_menu.GetPlayerBody().GetBodyPart("Organs")
							"Limbs":
								t = overworld_menu.GetPlayerBody().GetBodyPart("Limbs")
							"Head":
								t = overworld_menu.GetPlayerBody().GetBodyPart("Head")
							"Limb":
								t = body_panel.GetSelectedPart()
							"Organ":
								t = body_panel.GetSelectedPart()
						#for i in t: print(i.name)
						if useItem.OnUseOOC(overworld_menu.GetPlayer(), t):
							body_panel.SelectAllLimbs(false)
							body_panel.SelectAllOrgans(false)
							navBodyPanel = false
							useItem = null
						itemPanel.UpdateMenu()
					else:
						GameManager.PlayMenuSFX("Cancel")
						CloseUseItems()

func UpdateMenu():
	if invObjects.size() > 0:
		state = CurrentState.Inv
		if itemState >= invObjects.size() : itemState = 0
		invObjects[itemState].SelectButton()
		invItemDescription.text = invObjects[itemState].item.description
	else:
		state = CurrentState.Header
		invItemDescription.text = ""

func CloseUseItems():
	itemPanel.CloseMenu()
	GameManager.PlayMenuSFX("Cancel")
	PopulateInventoryUI([left_list,right_list], 20, false, 24, GetHeaderItemTags(headerState))
	state = CurrentState.Inv
	UpdateMenu()

# =========================
# INVENTORY HELPERS
# =========================

func PopulateInventoryUI(invContainer, maxItems, includeNull, fontSize, tags : Array[Global.ItemTags]):
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
	if tags.is_empty() : itemsList = overworld_menu.GetPlayerInv().GetItems()
	else:
		for tag in tags:
			itemsList = overworld_menu.GetPlayerInv().GetItemsTagged(tag)
	for item in itemsList:
		if shown >= maxItems:
			break

		var btn = item_button_scene.instantiate()
		invContainer[index % invContainer.size()].add_child(btn)
		btn.Setup(item, overworld_menu.GetPlayerInv().items[item], fontSize)
		btn.SetButtonAvailableOverworld(overworld_menu.GetPlayer())
		invObjects.append(btn)
		index += 1
		shown += 1
