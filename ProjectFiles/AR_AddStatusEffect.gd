class_name AR_AddStatusEffect extends ActionResource
@export var statusEffect : Global.StatusEffectTypes
@export var applyStatusChance : int = 100

func Do(_user : Entity, _target):
	var rand = randi() % 100 + 1
	if applyStatusChance >= rand:
		return ["SEffect", Global.GetStatusEffect(statusEffect)]
	return null
