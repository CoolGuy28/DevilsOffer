class_name Action_Utility extends Action

@export var useAction : Array[ActionResource]
@export var focus : String = ""

func DoAction(user : Entity, target):
	healing = 0
	bloodDamage = 0
	
	RunActionResources(useAction, user, target)
	
	if healing != 0 : user.Heal(healing, target)
	if bloodDamage != 0 : user.AdjustBlood(bloodDamage)
	ActionEnded.emit()
	return {
		"heal": healing,
		"bld": bloodDamage
	}

func RunActionResources(arr : Array[ActionResource], user : Entity, target):
	for i in arr:
		var r = i.Do(user, target)
		if r is Array:
			for j in range(0, r.size(), 2):
				if j + 1 >= r.size():
					break
				var type = r[j]
				var amount = r[j + 1]
				if type is int:
					damage[type] = damage.get(type, 0) + amount
				elif type is String:
					match type:
						"Heal":
							healing += amount
						"Bleed":
							bloodDamage += amount

func GetActionInfo(_user : Entity) -> String:
	var rString : String = actionName
	rString += "\n" + "Used On: " + focus
	rString += "\n" + GetHealText()
	rString += "\n" + smallDescription
	return rString

func GetHealText() -> String:
	var rString : String = "Heal: "
	for i in useAction:
		if i is AR_HealRoll:
			if i.dCount > 0 && i.dDie > 0:
				rString += str(i.dCount) + "d" + str(i.dDie)
			var dBonusVal : int = i.dBonus
			if dBonusVal > 0 : rString += "+" + str(dBonusVal)
	return rString
