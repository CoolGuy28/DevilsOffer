class_name InfoDisplayer extends PanelContainer
@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer
const TEXT_SCENE = preload("uid://c86t42rdws6gn")
const INFO_DISPLAY_SLIDER_DISPLAY = preload("uid://bflvqy6tcvie2")

func AddText(message : String):
	var textDisp = TEXT_SCENE.instantiate()
	v_box_container.add_child(textDisp)
	var text : RichTextLabel = textDisp.get_child(0)
	text.text = message

func AddSlider(val : int , maxVal : int):
	var sliderDisp = INFO_DISPLAY_SLIDER_DISPLAY.instantiate()
	v_box_container.add_child(sliderDisp)

	var barFill : Panel = sliderDisp.get_child(0).get_child(0).get_child(0)

	if maxVal <= 0:
		return

	barFill.pivot_offset.x = 0
	barFill.scale.x = clamp(float(val) / float(maxVal), 0.0, 1.0)
	

func ClearContainer():
	for child in v_box_container.get_children():
		child.queue_free()
