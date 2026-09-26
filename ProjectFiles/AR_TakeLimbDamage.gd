class_name AR_TakeLimbDamage extends ActionResource
@export var damage : int
@export var dType : Global.DamageType = Global.DamageType.Bludgeoning

func Do(_user : Entity, _target):
	if _target is Array[PlayerBodyPart]:
		_user.TakeLimbDamage({dType: damage} as Dictionary[Global.DamageType, int], _target)
	return null
