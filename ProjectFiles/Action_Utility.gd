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
