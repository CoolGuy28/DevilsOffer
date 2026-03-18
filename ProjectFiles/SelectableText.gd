class_name SelectableText extends RichTextLabel
@onready var panel: Panel = $Panel

func SelectButton():
	panel.show()

func DeselectButton():
	panel.hide()
