class_name Enemy extends Entity
@onready var BattleUI: Enemy_BattleUI = $Battle_UI
@export var globalStatusEffects : Array[StatusEffect]
@export var relationshipType : String = ""
@export var friendlyThreshold : int
@export var interactions : Dictionary[String, bool]
@export var dead : bool
@export var looted : bool
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var enemy_dialogue: EnemyDialogue = $EnemyDialogue
signal InteractionEnded()

@export var playSoundOverworld : String
#@export var beginBattleSFX : AudioStream
#@export var randSoundsEffects : Array[AudioStream]
#@export var randSFXTimer : Vector2

func _ready() -> void:
	super()
	for i in BattleUI.enemyParts:
		i.enemy = self
	BattleUI.hide()
	await get_tree().process_frame
	if dead: KillEnemy()
	#if !randSoundsEffects.is_empty():
	#	MakeRandSFX()
	PlaySFX(playSoundOverworld)
	pass 

func GetEnemyBattle():
	audioNode.stop()
	return BattleUI

func GetEnemyAction(actionCount: int, baCount: int, usedLimbs: Array[EnemyBodyPart]):
	var randActionArray: Array[Action_Enemy]
	for ea in BattleUI.GetEnemyActions():
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

func TakeDamage(_damage : Dictionary[Global.DamageType, int]):
	var combDmg : int = 0
	for i in BattleUI.GetEnemyParts():
		if !i.damagedPart:
			for dmgType in _damage:
				combDmg += i.TakeDamage(_damage[dmgType], dmgType)
	return combDmg

func Heal(heal : int, healTargets : Array[EnemyBodyPart] = []):
	var h = super(heal, healTargets)
	var parts = healTargets
	if parts.is_empty():
		parts.append(BattleUI.GetEnemyParts().pick_random())
	if parts != null : 
		for part in parts:
			part.Heal(h)

func KillEnemy():
	dead = true
	var hurtbox : CollisionShape2D = find_child("HurtBox").get_child(0)
	hurtbox.disabled = true
	set_collision_layer_value(5, false)
	animatedSprite.DisallowMovementAnim(true)
	PlayAnimation("Death", true)

func HasStatusEffects() -> bool:
	if globalStatusEffects.size() > 0: return true
	for i in BattleUI.GetEnemyParts(): 
		if !i.damagedPart && i.statusEffects.size() > 0: return true
	return false

func AddStatusEffect(statusEffect : StatusEffect, target : EnemyBodyPart = null):
	for i in GetStatusImmunities():
		if statusEffect == Global.GetStatusEffect(i):
			return
	if statusEffect is StatusEffect_Limb:
		var t : EnemyBodyPart = target
		if t == null || t is not EnemyBodyPart:
			GainStatusEffectAllLimbs(statusEffect)
		else: t.AddStatusEffect(statusEffect)
	else:
		if !globalStatusEffects.has(statusEffect):
			globalStatusEffects.append(statusEffect)
			statusEffect.OnGain(self)

func GainStatusEffectAllLimbs(statusEffect : StatusEffect_Limb):
	for i in BattleUI.GetEnemyParts():
		i.AddStatusEffect(statusEffect)

func RemoveStatusEffect(_statusEffectTag : String, _target):
	for i in globalStatusEffects:
		if i.tags.has(_statusEffectTag) : 
			i.OnEnd(self)
			globalStatusEffects.erase(i)

func TickStatusEffects():
	for globalEffect in globalStatusEffects:
		globalEffect.OnTick(self)
	for parts in BattleUI.GetEnemyParts():
		parts.TickStatusEffects()

func UpdateActionPoints():
	for i in BattleUI.GetEnemyActions():
		i.UpdatePoints()

var item : Item
var amount : int
func GetLoot():
	var loot = enemy_dialogue.GetLoot()
	item = loot[0]
	amount = loot[1]

var allowFight : bool = false
func Interact(_player : Player, collide : bool = false):
	if dead != true:
		if relationshipType != "":
			if _player.GetRelations().GetReputationType(relationshipType) >= friendlyThreshold:
				if collide : return
				GameManager.SetPause(true)
				allowFight = false
				BeginDialogue("Overworld", _player)
				await DialogueManager.dialogue_ended
				GameManager.SetPause(false)
				if !allowFight: return
		_player.BeginBattle(self)
	else:
		BeginDialogue("LootBody", _player)
	InteractionEnded.emit()

func BeginDialogue(dialogueString : String, _player : Player):
	if enemy_dialogue.GetDialogue() != null:
		DialogueManager.show_dialogue_balloon(enemy_dialogue.GetDialogue(), dialogueString, [self, { "player" = _player }, { "relation" = _player.GetRelations() }])

#func MakeRandSFX():
#	await get_tree().create_timer(randf_range(randSFXTimer.x, randSFXTimer.y)).timeout
#	if !GameManager.GetCombatState():
#		PlaySFX(randSoundsEffects.pick_random(), 0.35)
#	MakeRandSFX()

func SetAdjustedStatComponent():
	adjustedStats.CopyStatComponent(baseStats)
	adjustedStats.UpdateValues()
	for i in BattleUI.GetEnemyParts():
		if i.damagedPart == true && i.destroyedStatChange != null:
			adjustedStats.AddStatComponent(i.destroyedStatChange)
	for i in globalStatusEffects:
		if i is StatusEffect_ChangeStat:
			adjustedStats.AddStatComponent(i.statChange)

func GetInteraction(k : String):
	var i = interactions[k]
	if i != null:
		return i
	return false
