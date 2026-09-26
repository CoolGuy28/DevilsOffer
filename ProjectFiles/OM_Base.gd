class_name OM_Base extends PanelContainer
var overworld_menu : OverworldMenu

func DisplayMenu():
	pass

func CloseMenu():
	visible = false
	SetNoneState()
	pass

func SetDefaultState(): pass

func SetNoneState(): pass

func UpdateMenu(): pass

func InputNav(_input : String):
	pass

func ClearInventoryUI(invContainer):
	for c in invContainer:
		for child in c.get_children():
			child.queue_free()

func NavigateMenu(dir : int, arr : Array, stateInt : int):
	var num : int = stateInt
	if arr.size() == 0:
		return 0

	num = clamp(num, 0, arr.size()-1)

	arr[num].DeselectButton()

	num += dir

	if num >= arr.size():
		num = 0
	if num < 0:
		num = arr.size()-1

	arr[num].SelectButton()
	return num

func SetOverworldM(om : OverworldMenu):
	overworld_menu = om
