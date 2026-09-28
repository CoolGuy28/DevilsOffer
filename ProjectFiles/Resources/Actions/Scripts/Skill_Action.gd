class_name Skill_Action extends Skill
@export var action : Action
@export var OOCAction : Action_Utility
@export var bonusAction : bool
@export var cost : int
@export var costType : String = "Blood"

func OnUse(player : Player):
	if cost > 0:
		match costType:
			"Flesh":
				player.TakeDamage({Global.DamageType.Bleed : cost})
			"Exhaustion":
				player.AdjustExhaustion(-cost)
			"Blood", _:
				player.AdjustBlood(-cost)

func CanUse(player : Player):
	if action == null: return false
	if cost > 0:
		match costType:
			"Exhaustion":
				return true
			"Blood","Flesh",_:
				if player.currentHealth > 0 + cost:
					return true
		return false
	return true

func OnUseOOC(player : Player):
	var focusString = OOCAction.focus
	var target = player
	if focusString != "":
		target = player.GetBody().GetBodyPart(focusString)
	var _result = await OOCAction.DoAction(player, target)
	OnUse(player)

func CanUseOOC(_player : Player):
	if OOCAction != null : return true
	else : return false
