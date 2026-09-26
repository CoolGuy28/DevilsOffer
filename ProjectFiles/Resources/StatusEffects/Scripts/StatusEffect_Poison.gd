class_name StatusEffect_Poison extends StatusEffect_Limb
@export var poisonDamage : int = 3
@export var spreadChance : int = 8

func OnTick(_target):
	_target.TakeDamage(poisonDamage, Global.DamageType.Poison)
	for i in _target.GetAdjacentParts():
		if !i.IsDestroyed() && randi() % 100 + 1 <= spreadChance:
			i.AddStatusEffect(self)
