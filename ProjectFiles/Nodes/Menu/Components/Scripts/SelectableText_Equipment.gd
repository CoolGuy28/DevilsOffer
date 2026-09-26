class_name SelectableText_Equipment extends SelectableText
var item : Item

func _ready() -> void:
	slotTitle = text
	var itemStr = "None"
	if item != null: itemStr = item.itemName
	text = "%-10s %10s" % [slotTitle, itemStr]

func SelectButton():
	super()

func DeselectButton():
	super()

func SetEquippedItem(i : Item):
	item = i
	var itemStr = "None"
	if item != null: itemStr = item.itemName
	text = "%-10s %10s" % [slotTitle, itemStr]
