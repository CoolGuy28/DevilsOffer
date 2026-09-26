class_name AR_RemoveStatusEffect extends ActionResource
@export var statusEffectTag : String = "Blood"

func Do(_user : Entity, _target):
	_user.RemoveStatusEffect(statusEffectTag, _target)
	return null
