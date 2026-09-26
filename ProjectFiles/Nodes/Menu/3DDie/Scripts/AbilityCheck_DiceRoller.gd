class_name AbilityCheck_DiceRoller extends Node3D
signal EndD20Roll(i : int)
@onready var firstDie : PhysicsD20 = $D20/Dice_d20
@onready var secondDie : PhysicsD20 = $D21/Dice_d20
var hasAdvantage : int
var firstDieResult : int = 0
var secondDieResult : int = 0

func DisableDice():
	firstDie.set_process(false)
	secondDie.set_process(false)
	firstDie.hide()
	secondDie.hide()

func RollDice(adv : int = 0) -> void:
	hasAdvantage = adv
	firstDie.set_process(true)
	firstDie.show()
	firstDieResult = 0
	firstDie.EndD20Roll.connect(_on_first_die_finished, CONNECT_ONE_SHOT)	
	firstDie.RollD20()
	if hasAdvantage != 0:
		secondDie.set_process(true)
		secondDie.show()
		secondDieResult = 0
		secondDie.EndD20Roll.connect(_on_second_die_finished, CONNECT_ONE_SHOT)
		secondDie.RollD20()

func _on_first_die_finished(result : int) -> void:
	firstDieResult = result
	if hasAdvantage != 0:
		_check_both_done()
	else:
		EndD20Roll.emit(firstDieResult)

func _on_second_die_finished(result : int) -> void:
	secondDieResult = result
	_check_both_done()

func _check_both_done():
	if firstDieResult != 0 and secondDieResult != 0:
		if hasAdvantage < 0:
			if firstDieResult <= secondDieResult:
				EndD20Roll.emit(firstDieResult)
			else:
				EndD20Roll.emit(secondDieResult)
		else:
			if firstDieResult >= secondDieResult:
				EndD20Roll.emit(firstDieResult)
			else:
				EndD20Roll.emit(secondDieResult)
