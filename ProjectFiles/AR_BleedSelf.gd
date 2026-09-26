class_name AR_BleedSelf extends ActionResource
@export var bloodAmount : int

func Do(_user : Entity, _target):
	_user.AdjustBlood(-bloodAmount)
	return null
