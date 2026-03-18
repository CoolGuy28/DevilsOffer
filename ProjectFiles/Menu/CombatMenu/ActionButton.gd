class_name ActionButton extends Sprite2D
var buttonDisabled : bool
@export var action : bool
@export var bonusAction : bool
signal press()

func SelectButton():
	if !buttonDisabled:
		modulate = Color(1,1,1)
	else:
		modulate = Color(0.4,0.4,0.4)
	pass

func DeselectButton():
	if !buttonDisabled:
		modulate = Color(0.6,0.6,0.6)
	else:
		DisableButton()
	pass

func DisableButton():
	buttonDisabled = true
	modulate = Color(0.2,0.2,0.2)
	pass

func PressButton():
	if buttonDisabled == false:
		emit_signal("press")
	pass
