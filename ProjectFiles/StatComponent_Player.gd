class_name StatComponent_Player extends StatComponent
@export var maxHealth : int
@export var physicalDmgMult : float
@export var occultDmgMult : float
@export var coldDmgMult : float
@export var skills : Array[Skill]

func CopyStatComponent(i : StatComponent):
	super(i)
	if i is StatComponent_Player:
		maxHealth = i.maxHealth
		physicalDmgMult = i.physicalDmgMult
		occultDmgMult = i.occultDmgMult
		coldDmgMult = i.coldDmgMult
		skills.clear()
		skills = i.skills.duplicate(true)

func AddStatComponent(i : StatComponent):
	if i != null:
		super(i)
		if i is StatComponent_Player:
			maxHealth += i.maxHealth
			physicalDmgMult += i.physicalDmgMult
			occultDmgMult += i.occultDmgMult
			coldDmgMult += i.coldDmgMult
			skills.append_array(i.skills)

func SetZero():
	super()
	maxHealth = 0
	physicalDmgMult = 0
	occultDmgMult = 0
	coldDmgMult = 0
	skills.clear()

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
