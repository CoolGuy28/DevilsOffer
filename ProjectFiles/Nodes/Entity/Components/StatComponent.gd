class_name StatComponent extends SaveKitResource
@export var stats : Array[int] = [0,0,0,0] #str, dex, knw, wis
@export var AC : int = 0
@export var MC : int = 0
@export var exhaustion : int = 0
@export var legs = 0
@export var moveSpeed : float = 0
@export var crawlSpeed : float = 0
@export var swimSpeed : float = 0
@export var sprintSpeed : float = 0
@export var actionCount : int = 0
@export var bonusActionCount : int = 0
@export var stateBonus : int = 0
@export var dmgResist: Dictionary[Global.DamageType, Global.DamageResistType]

func CopyStatComponent(i : StatComponent):
	stats = i.stats.duplicate(true)
	AC = i.GetAC()
	MC = i.GetMC()
	exhaustion = i.exhaustion
	legs = i.legs
	moveSpeed = i.GetMoveSpeed()
	crawlSpeed = i.crawlSpeed
	swimSpeed = i.swimSpeed
	sprintSpeed = i.sprintSpeed
	actionCount = i.actionCount
	bonusActionCount = i.bonusActionCount
	stateBonus = i.stateBonus
	dmgResist = i.dmgResist.duplicate(true)

func AddStatComponent(i : StatComponent):
	if i != null:
		for j in range(stats.size()):
			stats[j] += i.stats[j]
		AC += i.GetAC()
		MC += i.GetMC()
		exhaustion += i.exhaustion
		legs += i.legs
		moveSpeed += i.moveSpeed
		crawlSpeed += i.crawlSpeed
		swimSpeed += i.swimSpeed
		sprintSpeed += i.sprintSpeed
		actionCount += i.actionCount
		bonusActionCount += i.bonusActionCount
		stateBonus += i.stateBonus
		#for j in range(dmgResist.size()):
			#dmgResist.has()

func UpdateValues():
	AC = AC + stats[1]
	MC = MC + stats[2]
	stateBonus = stateBonus - (exhaustion*2)

func SetStat(index : int, i : int):
	stats[index] = i;

func AdjustStat(index : int, i : int):
	stats[index] += i;

func SetZero():
	for j in range(stats.size()):
		stats[j] = 0
	AC = 0
	MC = 0
	exhaustion = 0
	actionCount = 0
	bonusActionCount = 0
	stateBonus = 0
	dmgResist.clear()
	moveSpeed = 0.0
	crawlSpeed = 0.0
	swimSpeed = 0.0
	sprintSpeed = 0.0
	legs = 0

func save_to_dict(s: SaveKitSerializer) -> Dictionary:
	var data = super(s)
	data["stats"] = s.encode_var(stats)
	data["dmgResist"] = s.encode_var(dmgResist)
	return data

func load_from_dict(s: SaveKitDeserializer, data: Dictionary) -> void:
	super(s, data)
	stats.clear()
	stats.append_array(s.decode_var(data["stats"], TYPE_ARRAY))
	dmgResist.clear()
	var decoded = s.decode_var(data["dmgResist"],TYPE_DICTIONARY)
	if decoded is Dictionary:
		for key in decoded:
			dmgResist[key] = decoded[key]

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
func GetMoveSpeed(sprinting : bool = false, swimming : bool = false):
	var curSpeed = moveSpeed
	if legs <= 0 : curSpeed = crawlSpeed
	if sprinting : curSpeed *= sprintSpeed
	if swimming : curSpeed *= swimSpeed
	return curSpeed

func GetStateBonus():
	return stateBonus
func GetExhaustion():
	return exhaustion
func AdjustExhaustion(i : int):
	exhaustion += i
	if exhaustion < 0 : exhaustion = 0
func GetDamageResist(type : Global.DamageType):
	return 1.0
func HasSkill(_search : String):
	return false
func GetUsableSkills() -> Array[Skill_Action]:
	var a : Array[Skill_Action]
	return a
