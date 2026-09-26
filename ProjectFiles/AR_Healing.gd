class_name AR_HealRoll extends ActionResource
@export var dCount : int = 1
@export var dDie : int = 6
@export var dBonus : int

func Do(_user : Entity, _target):
	var heal : int = 0
	#roll number of die
	for i in dCount:
		heal += randi_range(1, dDie)
	#add damage bonuses
	heal += dBonus
	if heal < 0:
		heal = 0
	return ["Heal", heal]
