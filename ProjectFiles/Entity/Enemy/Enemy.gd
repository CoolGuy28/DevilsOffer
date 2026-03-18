class_name Enemy extends Entity
@onready var BattleUI: Node2D = $BattleUI
var enemyParts : Array[EnemyBodyPart]
var enemyActions : Array[Action_Enemy]
var globalStatusEffects : Array[StatusEffect]
var dead : bool
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	super()
	for i in BattleUI.get_children():
		enemyParts.append(i)
		i.SetEnemy(self)
		for j in i.get_children():
			if j is EnemyBodyPart:
				enemyParts.append(j)
				j.SetEnemy(self)
			elif j is Action_Enemy:
				enemyActions.append(j)
			for k in j.get_children():
				if k is Action_Enemy:
					enemyActions.append(k)
	BattleUI.hide()
	pass 

func GetEnemyBattle():
	return BattleUI

func GetEnemyAction(actionCount: int, baCount: int, usedLimbs: Array[EnemyBodyPart]):
	var randActionArray: Array[Action_Enemy]
	for ea in enemyActions:
		var pointAmount: int = ea.currentPoints
		if pointAmount > 0:
			if ea.GetParent().currentPartHealth <= 0:
				pointAmount = 0
			elif ea.GetParent() in usedLimbs:
				pointAmount = 0
			elif !ea.bonusAction and actionCount <= 0:
				pointAmount = 0
			elif ea.bonusAction and baCount <= 0:
				pointAmount = 0
			for _i in range(pointAmount):
				randActionArray.append(ea)
	if randActionArray.size() > 0:
		return randActionArray.pick_random()
	return null

func TakeDamage(damage : int, dmgType : Global.DamageType):
	var combDmg : int = 0
	for i in enemyParts:
		combDmg += i.TakeDamage(damage, dmgType)
	return combDmg

func Heal(heal : int, type : String):
	var h = super(heal, type)
	match type:
		"All", _:
			for i in enemyParts:
				if !i.damagedPart : i.Heal(h)

func KillEnemy():
	dead = true
	var hurtbox : CollisionShape2D = find_child("HurtBox").get_child(0)
	hurtbox.disabled = true
	collision_shape_2d.disabled = true

func AddStatusEffect(statusEffect : StatusEffect, _target): 
	GainStatusEffect(statusEffect, _target)

func HasStatusEffects() -> bool:
	if globalStatusEffects.size() > 0: return true
	for i in enemyParts: 
		if !i.damagedPart && i.statusEffects.size() > 0: return true
	return false

func GainStatusEffect(statusEffect : StatusEffect, target : EnemyBodyPart = null):
	if statusEffect is StatusEffect_Limb:
		var t : EnemyBodyPart = target
		if t == null || t is not EnemyBodyPart:
			t = enemyParts[0]
		t.AddStatusEffect(statusEffect)
	else:
		if !globalStatusEffects.has(statusEffect):
			globalStatusEffects.append(statusEffect)
			statusEffect.OnGain(self)

func RemoveStatusEffect(statusEffect : StatusEffect):
	globalStatusEffects.erase(statusEffect)

func TickStatusEffects():
	for globalEffect in globalStatusEffects:
		globalEffect.OnTick(self)
	for parts in enemyParts:
		parts.TickStatusEffects()

func UpdateActionPoints():
	for i in enemyActions:
		i.UpdatePoints()

func SetAdjustedStatComponent():
	adjustedStats.CopyStatComponent(baseStats)
	adjustedStats.UpdateValues()
	for i in enemyParts:
		if i.damagedPart == true && i.destroyedStatChange != null:
			adjustedStats.AddStatComponent(i.destroyedStatChange)
	for i in globalStatusEffects:
		if i is StatusEffect_ChangeStat:
			adjustedStats.AddStatComponent(i.statChange)
