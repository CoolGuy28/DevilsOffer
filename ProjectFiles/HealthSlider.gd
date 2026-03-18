class_name HealthSlider extends Control
var maxVal : int
var currentVal : int
@onready var value: RichTextLabel = $Value
@onready var slider_bar: Sprite2D = $SliderBar

func IntialiseSlider(mVal : int, cVal : int):
	maxVal = mVal
	currentVal = cVal
	value.text = str(cVal)
	slider_bar.scale = Vector2(float(currentVal)/maxVal, 1)

func UpdateSlider(cVal: int):
	currentVal = cVal
	value.text = str(cVal)
	slider_bar.scale = Vector2(float(currentVal)/maxVal, 1)

var healthTween: Tween
func UpdateSliderSlide(cVal: int):
	currentVal = cVal
	healthTween = create_tween()
	healthTween.tween_property(slider_bar, "scale:x", float(currentVal)/maxVal, 0.8) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	value.text = str(cVal)
