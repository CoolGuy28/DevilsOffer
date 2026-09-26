class_name PlayerBody extends Node
@onready var player: Player = $".."
@export_storage var globalStatusEffects : Array[StatusEffect]
@export var bodyStats : StatComponent_Player
@export var bodyParts : Array[PlayerBodyLimb] #0Head,1Torso,2RARM,3LARM,4RLEG,5LLEG
@export var organs : Array[PlayerBodyPart] #0EYE,1Lung,2HEART,3Liver,4RKIDNEY,5LKIDNEY

func HasStatusEffects() -> bool:
	if globalStatusEffects.size() > 0: return true
	for i in bodyParts: 
		if i.statusEffects.size() > 0: return true
	return false

func AddStatusEffect(statusEffect : StatusEffect, target : Array[PlayerBodyPart] = []):
	if statusEffect is StatusEffect_Limb:
		if target.is_empty():
			GetRandomLimb().AddStatusEffect(statusEffect)
		else:
			for i in target:
				if i is PlayerBodyLimb:
					i.AddStatusEffect(statusEffect)
	else:
		if !globalStatusEffects.has(statusEffect):
			globalStatusEffects.append(statusEffect)
			statusEffect.OnGain(player)

func RemoveStatusEffect(statusEffectTag : String, target):
	if target is Player:
		for i in globalStatusEffects:
			if i.tags.has(statusEffectTag):
				i.OnEnd(player)
				globalStatusEffects.erase(i)
	elif target is Array:
		if target.is_empty():
			GetRandomLimb().RemoveStatusEffect(statusEffectTag)
		else:
			for i in target:
				if i is PlayerBodyLimb:
					i.RemoveStatusEffect(statusEffectTag)
	elif target is PlayerBodyLimb:
		target.RemoveStatusEffect(statusEffectTag)

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
		if i.IsDestroyed() && i.GetStatChanges() != null:
			bodyStats.AddStatComponent(i.GetStatChanges())
	for i in organs:
		if i.IsDestroyed() && i.GetStatChanges() != null:
			bodyStats.AddStatComponent(i.GetStatChanges())
	return bodyStats

func GetBodyPart(target : String) -> Array[PlayerBodyPart]:
	var returnArray : Array[PlayerBodyPart]
	match target:
		"All" : 
			for i in bodyParts:
				if !i.IsDestroyed():
					returnArray.append(i)
			for i in organs:
				if !i.IsDestroyed():
					returnArray.append(i)
		"Organs":
			for i in organs:
				if !i.IsDestroyed():
					returnArray.append(i)
		"Organ": returnArray.append(GetRandomOrgan())
		"Limbs": 
			for i in bodyParts:
				if !i.IsDestroyed():
					returnArray.append(i)
		"Limb": returnArray.append(GetRandomLimb())
		"Guard":
			returnArray.append(GetGuardedLimb())
		"Head": 
			returnArray.append(bodyParts[0])
		"Arm":
			returnArray.append(GetRandomArm())
			if returnArray.is_empty():
				returnArray.append(GetRandomLimb())
		"Leg":
			returnArray.append(GetRandomLeg())
			if returnArray.is_empty():
				returnArray.append(GetRandomLimb())
		#"", _: 
	return returnArray

func GetArmCount():
	var armCount : int = 0
	if !bodyParts[2].IsDestroyed() : armCount += 1
	if !bodyParts[3].IsDestroyed() : armCount += 1 
	return armCount

func GetRandomLimb() -> PlayerBodyLimb: 
	var returnArray : Array[PlayerBodyPart]
	for i in bodyParts:
		if !i.IsDestroyed():
			returnArray.append(i)
	return returnArray.pick_random()

func GetRandomArm() -> PlayerBodyLimb: 
	var returnArray : Array[PlayerBodyPart]
	if !bodyParts[3].IsDestroyed():
		returnArray.append(bodyParts[3])
	if !bodyParts[2].IsDestroyed():
		returnArray.append(bodyParts[2])
	if !returnArray.is_empty():
		return returnArray.pick_random()
	else:
		return null

func GetRandomLeg() -> PlayerBodyLimb: 
	var returnArray : Array[PlayerBodyPart]
	if !bodyParts[4].IsDestroyed():
		returnArray.append(bodyParts[4])
	if !bodyParts[5].IsDestroyed():
		returnArray.append(bodyParts[5])
	if !returnArray.is_empty():
		return returnArray.pick_random()
	else:
		return null

func GetRandomOrgan() -> PlayerBodyPart: 
	var returnArray : Array[PlayerBodyPart]
	for i in organs:
				if !i.IsDestroyed():
					returnArray.append(i)
	return returnArray.pick_random()

func GetGuardedLimb() -> PlayerBodyPart:
	if !bodyParts[3].IsDestroyed():
		return bodyParts[3]
	elif !bodyParts[2].IsDestroyed():
		return bodyParts[2]
	elif !bodyParts[4].IsDestroyed():
		return bodyParts[4]
	elif !bodyParts[5].IsDestroyed():
		return bodyParts[5]
	else: 
		return bodyParts[1]

func GetMainArm() -> PlayerBodyPart: 
	if GetArmCount() == 1:
		if !bodyParts[3].IsDestroyed():
			return bodyParts[3]
	return bodyParts[2]

func GetOffArm() -> PlayerBodyPart:
	if GetArmCount() == 1:
		if bodyParts[2].IsDestroyed():
			return bodyParts[2]
	return bodyParts[3]
