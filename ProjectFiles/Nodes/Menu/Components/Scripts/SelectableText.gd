class_name SelectableText extends RichTextLabel
@export var slotTitle : String
@onready var panel: Panel = $Panel

func SetText(s : String):
	text = slotTitle + s

func SelectButton():
	panel.show()

func DeselectButton():
	panel.hide()
