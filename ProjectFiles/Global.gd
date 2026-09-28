class_name Global extends Node
enum DamageType{Bludgeoning, Slashing, Piercing, Cold, Fire, Poison, Psychic, Bleed}
enum DamageResistType{Resistant, Vulnerable, Immune}
enum ItemTags{Weapon, Healing, Body, Accessory, Book, Scroll, Food, Key_, Equipment, UsableWeapon}
enum CombatActivation{OnBeginCombat, OnEndTurn, OnEndCombat, OnEnemyMiss, OnEnemyHit, OnPlayerCrit, OnPlayerGuard}
const BLOODSTAIN = preload("uid://cwfefjt6lhs2d")
const GLOBAL_DIALOGUE = preload("uid://6n7cay6mpivt")

static func GetAbilityNameFromInt(i : int) -> String:
	match i:
		0 : return "STR"
		1 : return "DEX"
		2 : return "INT"
		3 : return "WIS"
		_ : return "UNK"

static func GetGlobalDialogue():
	return GLOBAL_DIALOGUE

static func GetDamageType(type):
	return DamageType.keys()[type]

static func GetDamageColor(type : DamageType):
	match type:
		DamageType.Cold: return Color.AQUA
		DamageType.Fire: return Color.RED
		DamageType.Poison: return Color.PURPLE
		DamageType.Psychic: return Color.HOT_PINK
		_: return Color.WHITE

static func GetDamageResistTypeMod(type : DamageResistType):
	match type:
		DamageResistType.Resistant: return 0.5
		DamageResistType.Vulnerable: return 2.0
		DamageResistType.Immune: return 0
	return 1.0

static func GetDamageResist(type1 : DamageResistType, type2 : DamageResistType):
	if type1 == DamageResistType.Vulnerable:
		if type2 == DamageResistType.Immune: return DamageResistType.Resistant
		elif  type2 == DamageResistType.Resistant: return null
	elif type1 == DamageResistType.Resistant:
		if type2 == DamageResistType.Immune: return DamageResistType.Immune
		elif  type2 == DamageResistType.Vulnerable: return null
	if type1 == DamageResistType.Immune:
		if type2 == DamageResistType.Resistant: return DamageResistType.Immune
		elif  type2 == DamageResistType.Vulnerable: return DamageResistType.Resistant

static func GetDamageTypeAudio(type : DamageType):
	match type:
		DamageType.Slashing: return "res://SFX/Actions/Damage/Slashing/Sword Impact Hit 1.wav"
		DamageType.Piercing: return "res://SFX/Actions/Damage/Slashing/Sword Impact Hit 2.wav"
		DamageType.Cold: return "res://SFX/Actions/Damage/Slashing/Sword Impact Hit 3.wav"
		DamageType.Fire: return "res://SFX/Actions/Damage/Fire/Fireball_1.wav"
		DamageType.Poison: return "res://SFX/Actions/Damage/Poison/Spray.wav"
		DamageType.Psychic: return "res://SFX/Actions/Damage/Poison/Spray_3.wav"
		DamageType.Bleed: return "res://SFX/Actions/Damage/Blood/Blood_squirt_3.wav"
		DamageType.Bludgeoning, _: return "res://SFX/Actions/Damage/Bludgeoning/Kick_or_punch_1.wav"

static func GetIntAsStr(i : int):
	var s : String = ""
	if i > 0 : s += "+"
	s += str(i)
	return s

static func RollD20(advantage : bool, disadvantage : bool):
	var d20 : int = randi_range(1, 20)
	if (advantage && !disadvantage):
		var newd20 : int = randi_range(1, 20)
		if newd20 > d20 : d20 = newd20
	if (disadvantage && !advantage):
		var newd20 : int = randi_range(1, 20)
		if newd20 < d20 : d20 = newd20
	return d20

enum StatusEffectTypes{Anxious, Prone, Blind, Paralysed, Restrained, Offbalance, Rage, Horny, Depressed,
	Bleed, HeavyBleed, Poisoned, Frostbite, Stun, Burn1, Burn2, Burn3, Nauseous}

const BLEEDING = preload("uid://b67xhgppdmxq2")
const FIRE_LVL_1 = preload("uid://d3alotoodnv3m")
const FIRE_LVL_2 = preload("uid://cxqloeevfbyfo")
const FIRE_LVL_3 = preload("uid://chjk4vyxdt4ik")
const FROSTBITE = preload("uid://1comqvish3jv")
const POISON = preload("uid://dowrur0wumso6")
const STUN = preload("uid://fkv1rj6edtd8")

static func GetBurning(i : int) -> StatusEffect_Fire:
	match i: 
		1: return FIRE_LVL_2
		2: return FIRE_LVL_3
		0, _: return FIRE_LVL_1

static func GetStatusEffect(statusEffect : StatusEffectTypes) -> StatusEffect:
	match statusEffect:
		StatusEffectTypes.Burn1: return FIRE_LVL_1
		StatusEffectTypes.Burn2: return FIRE_LVL_2
		StatusEffectTypes.Burn3: return FIRE_LVL_3
		StatusEffectTypes.Poisoned: return POISON
		StatusEffectTypes.Frostbite: return FROSTBITE
		StatusEffectTypes.Stun: return STUN
		StatusEffectTypes.Bleed, StatusEffectTypes.HeavyBleed,_ : return BLEEDING
