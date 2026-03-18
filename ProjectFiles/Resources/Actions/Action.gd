class_name Action extends Resource
@export var actionName : String
enum TargetType{HitAttack, SaveAttack, Healing}
@export var targetType : TargetType
@export var statMod : int
@export var occultAttack : bool
@export_category("Main Die")
@export var dieCount : int = 1
@export var damageDie : int = 6
@export var dontAddStatDmg : bool
@export var diceDmgBonus : int
@export var damageType : Global.DamageType = Global.DamageType.Bludgeoning
@export_category("Bonus Die")
@export var bnsDieCount : int = 0
@export var bnsDamageDie : int = 0
@export var bnsDamageType : Global.DamageType = Global.DamageType.Bludgeoning
@export var bnsDiceDmgBonus : int
@export_category("Attack Action")
@export var attackCount : int = 1
@export var hitBonus : int
@export var lifeSteal : bool
@export var applyStatusChance : Dictionary[StatusEffect, int]
@export_category("Healing")
@export var healOnHit : bool
@export var healDieCount : int
@export var healDie : int
@export var healDieBns : int
@export var healType : String = "All"
@export var giveConditions : Array[String]
@export var removeConditions : Array[String]
@export_category("Blood")
@export var bloodLifeSteal : bool
@export var bloodDieCount : int
@export var bloodDie : int
@export var bloodDieBns : int

func SetAction(name : String, dieCnt : int, dmgDie : int, stat: int, dmgType : Global.DamageType, bnsDmg: int):
	actionName = name
	dieCount = dieCnt
	damageDie = dmgDie
	statMod = stat
	damageType = dmgType
	diceDmgBonus = bnsDmg

func IsGuardableDamageType():
	if damageType <= 4:
		return true
	else:
		return false

func IsDmgDieUsed():
	if dieCount > 0 || diceDmgBonus > 0: return true
	else: return false

func GetActionDamage(pStat : int, crit : bool = false):
	var damage : int = 0
	var critDouble : int = 1
	if crit : critDouble = 2
	#roll number of die
	for i in dieCount * critDouble:
		damage += randi_range(1, damageDie)
	#add damage bonuses
	damage += diceDmgBonus
	if !dontAddStatDmg:
		damage += pStat
	if damage < 0:
		damage = 0
	return damage

func IsBnsDieUsed():
	if bnsDieCount > 0 || bnsDiceDmgBonus > 0: return true
	else: return false

func GetActionBnsDamage(crit : bool = false):
	var damage : int = 0
	var critDouble : int = 1
	if crit : critDouble = 2
	#roll number of die
	for i in bnsDieCount * critDouble:
		damage += randi_range(1, bnsDamageDie)
	#add damage bonuses
	damage += bnsDiceDmgBonus
	if damage < 0:
		damage = 0
	return damage

func IsHealDieUsed():
	if healDieCount > 0 || healDieBns > 0: return true
	else: return false

func GetActionHeal():
	var heal : int = 0
	#roll number of die
	for i in healDieCount:
		heal += randi_range(1, healDie)
	#add damage bonuses
	heal += healDieBns
	if heal < 0:
		heal = 0
	return heal

func IsBloodDieUsed():
	if bloodDieCount > 0 || bloodDieBns > 0: return true
	else: return false

func GetActionBloodDamage(crit : bool = false):
	var damage : int = 0
	var critDouble : int = 1
	if crit : critDouble = 2
	#roll number of die
	for i in bloodDieCount * critDouble:
		damage += randi_range(1, bloodDie)
	#add damage bonuses
	damage += bloodDieBns
	if damage < 0:
		damage = 0
	return damage

func GetDamageStr(pHit : int, pDmg : int):
	#Write Hit Bonus
	var text = "Hit: "
	var hit = pHit + hitBonus
	if hit < 0: text += "-"
	elif hit > 0: text += "+"
	text += str(hit) + "\n"
	#Write damage die
	if dieCount > 0:
		text += str(dieCount) + "d" + str(damageDie)
	var d = diceDmgBonus
	if !dontAddStatDmg:
		d += pDmg
	if d < 0: text += "-"
	elif d > 0: text += "+"
	text += str(d) + " " + Global.DamageType.keys()[damageType]
	#Add bonus damage type (eg 1d4 Pierce + 2d6 Fire)
	if bnsDieCount > 0 || bnsDiceDmgBonus > 0:
		text += " + "
		if bnsDieCount > 0:
			text += str(bnsDieCount) + "d" + str(bnsDamageDie)
		if bnsDiceDmgBonus > 0:
			text += bnsDiceDmgBonus
		text += Global.DamageType.keys()[bnsDamageType]
	#Add AttackCount
	if attackCount > 1:
		text += "\nAttacks: " + str(attackCount)
	return text

func GetActionHitBonus():
	return hitBonus
