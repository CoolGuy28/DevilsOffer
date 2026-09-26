class_name AR_DamageRoll extends ActionResource
@export var dCount : int = 1
@export var dDie : int = 6
@export var dBonus : int
@export var dType : Global.DamageType = Global.DamageType.Bludgeoning
@export var lifeSteal : bool

func Do(_user : Entity, _target):
	var damage : int = 0
	#roll number of die
	for i in dCount:
		damage += randi_range(1, dDie)
	#add damage bonuses
	damage += dBonus
	if damage < 0:
		damage = 0
	var arr : Array = [dType, damage]
	if lifeSteal: arr.append_array(["Heal", damage])
	return arr
