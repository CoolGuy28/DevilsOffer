class_name PlayerBodyLimb extends PlayerBodyPart
var statusEffects : Array[StatusEffect_Limb]

func DestroyPart():
	super()
	statusEffects.clear()

func AddStatusEffect(statusEffect : StatusEffect_Limb):
	if !statusEffects.has(statusEffect):
		statusEffects.append(statusEffect)
		statusEffect.OnGain(self)

func TickStatusEffects():
	for i in statusEffects:
		i.OnTick(self)

func GetEntity() -> Player:
	return get_parent().player
