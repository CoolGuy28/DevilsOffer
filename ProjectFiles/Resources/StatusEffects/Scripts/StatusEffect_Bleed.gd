class_name StatusEffect_Bleed extends StatusEffect_Limb
@export var bleedAmount : int = 3

func OnTick(_target):
	_target.GetEntity().AdjustBlood(-bleedAmount)
