class_name StatusEffect_Fire extends StatusEffect_Limb
@export var fireDamage : int = 3
@export var spreadChance : int = 8
@export var growChance : int = 15
@export var level : int = 0

func OnTick(_target):
	_target.TakeDamage(fireDamage, Global.DamageType.Fire)
	for i in _target.GetAdjacentParts():
		if i.statusEffects.has(Global.GetBurning(0)) || i.statusEffects.has(Global.GetBurning(1)) || i.statusEffects.has(Global.GetBurning(2)):
			continue
		if !i.IsDestroyed() && randi() % 100 + 1 <= spreadChance:
			i.AddStatusEffect(Global.GetBurning(0))
	if level != 2 && randi() % 100 + 1 <= growChance:
		if level == 0:
			_target.AddStatusEffect(Global.GetBurning(1))
		elif level == 1:
			_target.AddStatusEffect(Global.GetBurning(2))
		_target.RemoveStatusEffect(self)
