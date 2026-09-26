class_name PlayerBodyLimb extends PlayerBodyPart
@export_storage var statusEffects : Array[StatusEffect_Limb]
@export var adjacentParts : Array[PlayerBodyLimb]

func DestroyPart(destroyMessage : String):
	super(destroyMessage)
	statusEffects.clear()

func AddStatusEffect(statusEffect : StatusEffect_Limb):
	if !statusEffects.has(statusEffect):
		statusEffects.append(statusEffect)
		statusEffect.OnGain(self)

func RemoveStatusEffect(statusEffectTag : String):
	for i in statusEffects:
		if i.tags.has(statusEffectTag):
			i.OnEnd(self)
			statusEffects.erase(i)

func TickStatusEffects():
	for i in statusEffects:
		i.OnTick(self)

func GetEntity() -> Player:
	return get_parent().get_parent().player

func GetAdjacentParts():
	return adjacentParts

func GetStatusEffects():
	if !IsDestroyed() || !statusEffects.is_empty():
		return statusEffects
	else :
		return null
