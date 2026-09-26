class_name HealthSlider extends Control
var maxVal : int
var currentVal : int
@onready var value: RichTextLabel = $Value
@onready var slider_bar: Panel = $MarginContainer/Panel/SliderBar


func IntialiseSlider(mVal : int, cVal : int):
	maxVal = mVal
	currentVal = cVal
	value.text = str(cVal)
	await get_tree().process_frame
	var barFill : Panel = slider_bar
	if maxVal <= 0:
		return
	barFill.pivot_offset.x = 0
	barFill.scale.x = clamp(float(currentVal) / float(maxVal), 0.0, 1.0)

func UpdateSlider(cVal: int):
	currentVal = cVal
	value.text = str(cVal)
	var barFill : Panel = slider_bar
	if maxVal <= 0:
		return
	barFill.pivot_offset.x = 0
	barFill.scale.x = clamp(float(cVal) / float(maxVal), 0.0, 1.0)

var healthTween: Tween
func UpdateSliderSlide(cVal: int):
	currentVal = cVal
	healthTween = create_tween()
	healthTween.tween_property(slider_bar, "scale:x", float(currentVal)/maxVal, 0.8) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	value.text = str(cVal)
