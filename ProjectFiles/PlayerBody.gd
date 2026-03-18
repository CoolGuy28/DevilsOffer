class_name PlayerBody extends Node
@onready var player: Player = $".."
var globalStatusEffects : Array[StatusEffect]
@export var bodyStats : StatComponent_Player
@export var bodyParts : Array[PlayerBodyLimb]
@export var organs : Array[PlayerBodyPart]

func HasStatusEffects() -> bool:
	if globalStatusEffects.size() > 0: return true
	for i in bodyParts: 
		if i.statusEffects.size() > 0: return true
	return false

func GainStatusEffect(statusEffect : StatusEffect, target : PlayerBodyLimb = null):
	if statusEffect is StatusEffect_Limb:
		var t : PlayerBodyLimb = target
		if t == null || t is not PlayerBodyLimb:
			t = GetRandomLimb()
		t.AddStatusEffect(statusEffect)
	else:
		if !globalStatusEffects.has(statusEffect):
			globalStatusEffects.append(statusEffect)
			statusEffect.OnGain(player)

func RemoveStatusEffect(statusEffect : StatusEffect):
	globalStatusEffects.erase(statusEffect)

func TickStatusEffects():
	for globalEffect in globalStatusEffects:
		globalEffect.OnTick(player)
	for parts in bodyParts:
		parts.TickStatusEffects()

func SetBodyStats():
	bodyStats.SetZero()
	for i in globalStatusEffects:
		if i is StatusEffect_ChangeStat:
			bodyStats.AddStatComponent(i.statChange)
	for i in bodyParts:
		if i.destroyed && i.destroyedStatChange != null:
			bodyStats.AddStatComponent(i.destroyedStatChange)
	for i in organs:
		if i.destroyed && i.destroyedStatChange != null:
			bodyStats.AddStatComponent(i.destroyedStatChange)
	return bodyStats

func GetBodyPart(target : String):
	match target:
		"Organ": return GetRandomOrgan()
		"Limb": return GetRandomLimb()
		"", _: return null

func GetMainArm() : 
	return bodyParts[0]

func GetRandomLimb() : 
	return bodyParts.pick_random()

func GetRandomOrgan() : 
	return organs.pick_random()
