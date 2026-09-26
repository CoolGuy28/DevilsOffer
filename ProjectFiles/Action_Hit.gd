class_name Action_Hit extends Action
@export var abilityMod : int
@export var addDamageMod : bool = true
@export var hitBonus : int = 0
@export var extraAttacks : int = 0
@export var timeBtwExtHits : float = 0.4
@export var hitAnim : String
@export var critAction : Array[ActionResource]
@export var hitAction : Array[ActionResource]
@export var missAction : Array[ActionResource]

var mainDType : Global.DamageType

func DoAction(user : Entity, target):
	mainDType = GetMainDType()
	damage.clear()
	healing = 0
	bloodDamage = 0
	statusEffect.clear()
	
	#Roll HitDie
	var d20Roll = RollD20(user, target)
	if d20Roll > 0: 
		##CRIT 
		if d20Roll == 2: 
			if !critAction.is_empty(): RunActionResources(critAction, user, target) 
		#Hit 
		if !hitAction.is_empty(): RunActionResources(hitAction, user, target) 
	##Miss
	else: 
		if !missAction.is_empty(): RunActionResources(missAction, user, target)
	
	ActionEnded.emit()
	if addDamageMod && !damage.is_empty(): damage[mainDType] += user.GetDamageMod(abilityMod)
	return {
		"roll": d20Roll,
		"dmg": user.AdjustOutgoingDamage(damage),
		"heal": healing,
		"bld": bloodDamage,
		"stFx": statusEffect
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
						"SEffect":
							statusEffect.append(amount)

func GetMainDType() -> Global.DamageType:
	for i in hitAction:
		if i is AR_DamageRoll:
			return i.dType
	return Global.DamageType

func GetHitChance(user : Entity, target):
	if occultAction : return target.GetMC() - user.GetHitMod(abilityMod, occultAction) + hitBonus
	else : return target.GetAC() - user.GetHitMod(abilityMod, occultAction) + hitBonus

func RollD20(user : Entity, target):
	if hitBonus >= 20 : return 1
	var d20 : int = Global.RollD20(0, 0)
	print(" Hit: " + str(d20))
	var crit : bool = false
	if d20 >= 20 - user.GetCritStat() : crit = true
	#print("crit: " + str(crit))
	var rollValue : int = d20 + user.GetHitMod(abilityMod, occultAction) + hitBonus
	var toHitDC = 0
	print(rollValue)
	if occultAction : toHitDC = target.GetMC()
	else : toHitDC = target.GetAC()
	if rollValue >= toHitDC:
		if crit == true:
			return 2
		else:
			return 1
	else:
		return 0
