class_name AR_AddStatusEffectSelf extends ActionResource
@export var statusEffect : Global.StatusEffectTypes

func Do(_user : Entity, _target):
	_user.AddStatusEffect(Global.GetStatusEffect(statusEffect), _target)
	return null
