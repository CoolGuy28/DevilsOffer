class_name Action_Save extends Action
@export var baseSaveDC : int = 10
@export var saveDCMod : int = 2
@export var saveAbility : int = 2

@export var damages : Array[AR_DamageRoll]
@export var halfDamageOnSave : bool
@export var savedAction : Array[ActionResource]
@export var failedAction : Array[ActionResource]

func DoAction(_user : Entity, _target):
	pass

func GetActionInfo(user : Entity) -> String:
	var rString : String = actionName + "\n"
	rString += Global.GetAbilityNameFromInt(saveAbility) + str(baseSaveDC + user.GetSaveDCMod(saveDCMod))
	rString += "[font_size=10]"
	rString += "\nOn Fail: " + GetDamageText(user)
	rString += "\n" + smallDescription
	if halfDamageOnSave:
		rString += "\nOn Success: Take Half Damage"
	return rString

func GetDamageText(_user : Entity) -> String:
	var rString : String = ""
	var firstDamage : bool = true
	for i in damages:
		if i is AR_DamageRoll:
			if !firstDamage : rString += " + "
			if i.dCount > 0 && i.dDie > 0:
				rString += str(i.dCount) + "d" + str(i.dDie)
			var dBonusVal : int = i.dBonus
			if dBonusVal > 0 : rString += "+" + str(dBonusVal)
			rString += " " + Global.GetDamageType(i.dType)
			if firstDamage : firstDamage = false
	return rString
