class_name OverworldMenu extends Panel

signal close()

var inMenu : bool

@export var mainButtons : Array[Sprite2D]
var mainButtonIndex : int = 0
@export var mainButtonDeselectColor : Color

@onready var player: Player = $"../../.."

@export var menuPanels : Array[OM_Base]

func _ready() -> void:
	for i in menuPanels:
		i.SetOverworldM(self)
	CloseMenu()

# =========================
# MAIN FUNCTIONS
# =========================

func OpenMenu():
	process_mode = Node.PROCESS_MODE_ALWAYS
	show()
	inMenu = false
	mainButtonIndex = 0
	for i in mainButtons:
		i.modulate = mainButtonDeselectColor
	mainButtons[mainButtonIndex].modulate = Color.WHITE
	menuPanels[mainButtonIndex].DisplayMenu()

func CloseMenu():
	HideAllMenu()
	hide()
	close.emit()
	process_mode = Node.PROCESS_MODE_DISABLED

func GetInput(input : String):
	if !inMenu:
		if input == "up": 
			GameManager.PlayMenuSFX("Hover")
			MainButtonNav(-1)
		if input == "down": 
			GameManager.PlayMenuSFX("Hover")
			MainButtonNav(1)
		if input == "return": 
			GameManager.PlayMenuSFX("Cancel")
			CloseMenu()
		if input == "select": 
			GameManager.PlayMenuSFX("Select")
			menuPanels[mainButtonIndex].SetDefaultState()
			inMenu = true
	else:
		menuPanels[mainButtonIndex].InputNav(input)

func GetPlayer() -> Player:
	return player

func GetPlayerInv() -> PlayerInventory:
	return player.GetInventory()

func GetPlayerBody() -> PlayerBody:
	return player.GetBody()
# =========================
# MAIN MENU
# =========================

func MainButtonNav(dir : int):
	mainButtons[mainButtonIndex].modulate = mainButtonDeselectColor

	mainButtonIndex += dir
	if mainButtonIndex >= mainButtons.size():
		mainButtonIndex = 0
	if mainButtonIndex < 0:
		mainButtonIndex = mainButtons.size() - 1

	mainButtons[mainButtonIndex].modulate = Color.WHITE
	
	HideAllMenu()
	menuPanels[mainButtonIndex].DisplayMenu()

func HideAllMenu():
	for i in menuPanels:
		i.CloseMenu()

func SetInMenu(b : bool):
	inMenu = b
