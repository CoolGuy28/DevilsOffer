class_name Item_Button extends Control
@onready var panel: Panel = $Panel
var item : Item
var usable : bool
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func Setup(i: Item, quant: int, fontSize :int):
	item = i
	if item != null:
		rich_text_label.text = "[font_size=%d]%-20s x%d" % [fontSize, item.itemName, quant]
	else:
		rich_text_label.text = "Remove"
	DeselectButton()

func SelectButton():
	panel.self_modulate = Color.WHITE

func EnabledButton():
	rich_text_label.self_modulate = Color.WHITE

func DisabledButton():
	rich_text_label.self_modulate = Color.DIM_GRAY

func DeselectButton():
	panel.self_modulate = Color.TRANSPARENT

func SetButtonAvailable(player : Player, aCount : int, bCount : int):
	if item is Item_Usable:
		if item.CanUse(player):
			if item.bonusAction && bCount > 0:
				usable = true
				EnabledButton()
			elif !item.bonusAction && aCount > 0:
				usable = true
				EnabledButton()
			else : DisabledButton()
		else : DisabledButton()
	else : DisabledButton()

func OnUse(player : Player):
	if item is Item_Usable:
		item.OnUse(player)

func GetAction():
	if item is Item_Usable:
		return item.action
	else:
		return null

func IsBonusAction():
	if item is Item_Usable:
		return item.bonusAction
	else:
		return null
