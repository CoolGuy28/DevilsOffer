class_name StatusEffect_Poison extends StatusEffect_Limb
@export var poisonDamage : int = 4
@export var spreadChance : int = 25

func OnTick(_target):
	_target.TakeDamage(poisonDamage, Global.DamageType.Poison)
