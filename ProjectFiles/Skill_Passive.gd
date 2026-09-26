class_name Skill_Passive extends Skill
@export var passiveStats : StatComponent_Player

@export var activation : Global.CombatActivation
@export var action : Action

func GetPassiveAction(a : Global.CombatActivation):
	if action == null: return null
	if a == activation:
		return action
	return null
