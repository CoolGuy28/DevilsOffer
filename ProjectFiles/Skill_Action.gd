class_name Skill_Action extends Skill
@export var action : Action
@export var bonusAction : bool
@export var cost : int
@export var costType : String = "Blood"

func OnUse(player : Player):
	if cost > 0:
		match costType:
			"Flesh":
				player.TakeDamage(cost, Global.DamageType.Bleed)
			"Blood", _:
				player.AdjustBlood(-cost)

func CanUse(player : Player):
	if cost > 0:
		match costType:
			"Blood","Flesh",_:
				if player.currentHealth > 0 + cost:
					return true
		return false
	return true
