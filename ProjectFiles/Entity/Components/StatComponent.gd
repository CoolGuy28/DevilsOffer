class_name StatComponent extends Resource
@export var stats : Array[int] = [0,0,0,0] #str, dex, knw, per
@export var AC : int = 0
@export var MC : int = 0
@export var moveSpeed : float = 0
@export var actionCount : int = 0
@export var bonusActionCount : int = 0
@export var skillBonus : int = 0
@export var dmgResist: Dictionary[Global.DamageType, float]

func CopyStatComponent(i : StatComponent):
	stats.clear()
	stats = i.stats.duplicate(true)
	AC = i.GetAC()
	MC = i.GetMC()
	moveSpeed = i.GetMoveSpeed()
	actionCount = i.actionCount
	bonusActionCount = i.bonusActionCount
	skillBonus = i.skillBonus
	dmgResist.clear()
	dmgResist = i.dmgResist.duplicate(true)

func AddStatComponent(i : StatComponent):
	if i != null:
		for j in range(stats.size()):
			stats[j] += i.stats[j]
		AC += i.GetAC()
		MC += i.GetMC()
		moveSpeed += i.GetMoveSpeed()
		actionCount += i.actionCount
		bonusActionCount += i.bonusActionCount
		skillBonus += i.skillBonus
		for j in range(dmgResist.size()):
			dmgResist[j] += i.dmgResist[j]

func UpdateValues():
	AC = AC + stats[1]
	MC = MC + stats[2]

func SetStat(index : int, i : int):
	stats[index] = i;

func SetZero():
	for j in range(stats.size()):
		stats[j] = 0
	AC = 0
	MC = 0
	moveSpeed = 0
	actionCount = 0
	bonusActionCount = 0
	skillBonus = 0
	dmgResist.clear()

func PrintStatComponent():
	print("New StatCom")
	var a : int = 0
	for j in stats:
		print(str(a) + ": " + str(j))
		a += 1
	print("AC: " + str(AC))
	print("MC: " + str(MC))
	print("Mve: " + str(moveSpeed))
	print("A: " + str(actionCount))
	print("BA: " + str(bonusActionCount))

func GetAdvantage():
	return false
func GetDisadvantage():
	return false
func GetStat(index : int):
	return stats[index]
func GetAC():
	return AC
func GetMC():
	return MC
func GetMoveSpeed():
	return moveSpeed
func GetSkillBonus():
	return skillBonus
func GetDamageResist(type : Global.DamageType):
	var i : float = dmgResist.get(type, 1.0)
	if i < 0.0:
		i = 0.0
	elif i > 1.0:
		i = 2.0
	return i
func HasSkill(_search : String):
	return false
func GetUsableSkills() -> Array[Skill_Action]:
	var a : Array[Skill_Action]
	return a
