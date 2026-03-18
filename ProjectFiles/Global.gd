class_name Global extends Node
enum DamageType{Bludgeoning, Slashing, Piercing, Cold, Fire, Poison, Psychic, Bleed}
enum StatusEffect{Bleed, HeavyBleed, Poisoned, FrostBite, Stun, Burn1, Burn2, Burn3}

static func GetDamageType(type):
	return DamageType.keys()[type]

static func GetDamageColor(type : DamageType):
	match type:
		DamageType.Cold: return Color.AQUA
		DamageType.Fire: return Color.RED
		DamageType.Poison: return Color.PURPLE
		DamageType.Psychic: return Color.HOT_PINK
		_: return Color.WHITE
