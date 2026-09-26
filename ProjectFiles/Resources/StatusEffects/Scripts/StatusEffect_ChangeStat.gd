class_name StatusEffect_ChangeStat extends StatusEffect
@export var statChange : StatComponent_Player

func OnGain(_target): 
	_target.SetAdjustedStatComponent()

func OnEnd(_target):
	_target.SetAdjustedStatComponent()
