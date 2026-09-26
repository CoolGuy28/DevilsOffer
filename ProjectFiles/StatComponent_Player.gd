class_name StatComponent_Player extends StatComponent
@export var maxHealth : int
@export var maxBlood : int = 0
@export var physicalDmgMult : float
@export var occultDmgMult : float
@export var coldDmgMult : float
@export var viewDis : float
@export var torchBrightness : int = 0
@export var torchStrength : float
@export var skills : Array[Skill]
@export var permaExhaustion : int = 0
@export var statusImmunities : Array[Global.StatusEffectTypes]
@export var guardDamageReduction : int

func CopyStatComponent(i : StatComponent):
	super(i)
	if i is StatComponent_Player:
		maxHealth = i.maxHealth
		maxBlood = i.maxBlood
		physicalDmgMult = i.physicalDmgMult
		occultDmgMult = i.occultDmgMult
		coldDmgMult = i.coldDmgMult
		viewDis = i.viewDis
		torchBrightness = i.torchBrightness
		torchStrength = i.torchStrength
		skills = i.skills.duplicate(true)
		statusImmunities = i.statusImmunities.duplicate(true)
		permaExhaustion = i.permaExhaustion
		guardDamageReduction = i.guardDamageReduction

func AddStatComponent(i : StatComponent):
	if i != null:
		super(i)
		if i is StatComponent_Player:
			maxHealth += i.maxHealth
			maxBlood += i.maxBlood
			physicalDmgMult += i.physicalDmgMult
			occultDmgMult += i.occultDmgMult
			coldDmgMult += i.coldDmgMult
			viewDis += i.viewDis
			torchBrightness += i.torchBrightness
			torchStrength += i.torchStrength
			skills.append_array(i.skills)
			statusImmunities.append_array(i.statusImmunities)
			permaExhaustion += i.permaExhaustion
			guardDamageReduction += i.guardDamageReduction

func SetZero():
	super()
	maxHealth = 0
	maxBlood = 0
	physicalDmgMult = 0
	occultDmgMult = 0
	coldDmgMult = 0
	viewDis = 0
	torchBrightness = 0
	torchStrength = 0
	skills.clear()
	statusImmunities.clear()
	permaExhaustion = 0
	guardDamageReduction = 0

func save_to_dict(s: SaveKitSerializer) -> Dictionary:
	return super(s)

func load_from_dict(s: SaveKitDeserializer, data: Dictionary) -> void:
	super(s, data)

func HasSkill(search : String):
	for i in skills:
		if i.skillName == search:
			return true
	return false

func GetUsableSkills() -> Array[Skill_Action]:
	var a : Array[Skill_Action]
	for i in skills:
		if i is Skill_Action:
			a.append(i)
	return a

func GetPassiveSkills() -> Array[Skill_Passive]:
	var a : Array[Skill_Passive]
	for i in skills:
		if i is Skill_Passive:
			a.append(i)
	return a
