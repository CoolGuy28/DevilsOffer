class_name EnemyBodyPart extends Control
var partTextures : Array[EnemyBodyPartTexture]
@export var maxPartHealth : int
@export var dmgResist: Dictionary[Global.DamageType, Global.DamageResistType]
@export var limbImmunities : Array[Global.StatusEffectTypes]
@export var lethalPart : bool
@export var acBonus : int
@export var destroyedStatChange : StatComponent
@export var damagedPart : bool
@export var tags : Array[String]
var statusEffects : Array[StatusEffect_Limb]
var currentPartHealth : int
var enemy : Enemy
@export var destroyedPartSFX : AudioStream = preload("res://SFX/Actions/Damage/Blood/Blood_squirt_4.wav")
var disabled : bool
@export var changePhaseAtHealthLvl : Dictionary[int, int]
@export var allowedPhase : int = -1
const ATTACK_EFFECT = preload("res://Nodes/Menu/CombatMenu/AttackEffect.tscn")
const damageTextScene = preload("res://Nodes/Entity/Enemy/Damage_Text.tscn")
@onready var effectSpawnPoint: Control = $EffectSpawnPoint
@onready var animationPlayer: AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var conditionBox: HBoxContainer = $ConditionBox
var battleUI : Enemy_BattleUI
signal EmitNote(s : String)

@export_category("Stage")
@export var maxStage : int
@export var currentStage : int = 0
@export var setStageOnDamage : int = -1
@export var displayNoteAtStage : Dictionary[int, String]
@export var changeStageSFX : AudioStream = preload("res://SFX/Enemies/Gore_Wet_9.wav")
@export var playConstStreamSound : AudioStream = null

@export_category("AdjacentParts")
@export var adjacentParts : Array[EnemyBodyPart]
@export var upParts : Array[EnemyBodyPart]
@export var downParts : Array[EnemyBodyPart]
@export var leftParts : Array[EnemyBodyPart]
@export var rightParts : Array[EnemyBodyPart]

func Initialise(bui : Enemy_BattleUI) -> void:
	battleUI = bui
	currentPartHealth = maxPartHealth
	for i in get_children():
		if i is EnemyBodyPartTexture:
			partTextures.append(i)
	SetPartSprites()

func SetPartSprites():
	SetPartAnim()
	AdjustPartTextures()

func SetPartAnim():
	if animationPlayer == null : return
	if damagedPart == true:
		if animationPlayer.has_animation("Dead" + str(currentStage)):
			animationPlayer.play("Dead")
	else:
		if currentStage != 0 && animationPlayer.has_animation("Idle_" + str(currentStage + 1)):
			animationPlayer.play("Idle_" + str(currentStage + 1))
		elif animationPlayer.has_animation("Idle"):
			animationPlayer.play("Idle")

func SelectPart():
	for i in partTextures:
		i.KillTween()
	ChangeModulate(Color(2, 2, 2))

func DeselectPart():
	ChangeModulate(Color(1, 1, 1))

func ChangeModulate(c : Color):
	for i in partTextures:
		i.self_modulate = c

func AdjustPartTextures():
	for i in partTextures:
		i.SetTexture(enemy.name, self)

func EnablePart():
	show()
	disabled = false

func DisablePart():
	hide()
	disabled = true

func TakeDamage(damage : int, damageType : Global.DamageType, crit : bool = false, damagePos : Vector2 = Vector2.ZERO):
	var textString = ""
	var dmg : int = damage
	#Add Damage Resitences
	var dmgRes : float = GetDamageResist(damageType)
	if dmgRes != 1.0:
		dmg = int(dmg * dmgRes)
		match dmgRes:
			0.0: textString = "IMM"
			2.0: textString = "VUL"
			_: textString = "RES"
	# Create Damage Text
	if crit: textString += "CRIT"
	textString += str(dmg)
	CreateDamageText(textString, Global.GetDamageColor(damageType), damagePos)
	# Flash BodyPart Red When Damaged
	ChangeModulate(Color.FIREBRICK)
	for i in partTextures:
		i.TweenToWhite(1.5)
	# Decrease Part Health
	currentPartHealth -= dmg
	for i in changePhaseAtHealthLvl:
		if currentPartHealth <= i:
			battleUI.ChangePhase(changePhaseAtHealthLvl[i])
			changePhaseAtHealthLvl.erase(i)
	if currentPartHealth <= 0:
		KillPart()
	else:
		if setStageOnDamage != -1:
			SetStage(setStageOnDamage)
	return dmg

func Heal(heal : int):
	var textString = ""
	var h : int = heal
	textString += str(h)
	CreateDamageText(textString, Color.GREEN)

	# Flash BodyPart Red When Damaged
	#ChangeModulate(Color.DARK_GREEN)
	#for i in partTextures:
	#	i.TweenToWhite(1.5)

	# Decrease Part Health
	currentPartHealth += h
	if currentPartHealth > maxPartHealth: currentPartHealth = maxPartHealth
	return h

const textDist : float = 14
func CreateDamageText(textString : String, colour : Color, damagePos : Vector2 = Vector2.ZERO):
	var damage_label: DamageText = damageTextScene.instantiate()
	add_child(damage_label)
	if damagePos == Vector2.ZERO:
		damage_label.position = GetDamagePos()
	else : damage_label.position = damagePos
	damage_label.set_damage_text(textString, colour)

func CreateDamageEffect(_effect : String, damagePos : Vector2 = Vector2.ZERO):
	var damageEffect: AnimatedSprite2D = ATTACK_EFFECT.instantiate()
	add_child(damageEffect)
	if damagePos == Vector2.ZERO:
		damageEffect.position = GetDamagePos()
	damageEffect.play()
	await get_tree().create_timer(2).timeout
	damageEffect.queue_free()

func GetDamagePos():
	return effectSpawnPoint.position + Vector2(randfn(-textDist,textDist), randfn(-textDist,textDist))

func KillPart():
	if (lethalPart):
		enemy.KillEnemy()
	damagedPart = true
	PlaySound(destroyedPartSFX)
	SetPartSprites()
	statusEffects.clear()
	UpdateStatusEffectIcons()
	enemy.SetAdjustedStatComponent()

func AttackMiss():
	CreateDamageText("Miss", Color.WHITE)

func AddStatusEffect(statusEffect):
	for i in GetStatusImmunities():
		if statusEffect == Global.GetStatusEffect(i):
			return
	if !statusEffects.has(statusEffect):
		statusEffects.append(statusEffect)
		statusEffect.OnGain(self)
	UpdateStatusEffectIcons()


func RemoveStatusEffect(statusEffect):
	if statusEffects.has(statusEffect):
		statusEffects.erase(statusEffect)
		statusEffect.OnEnd(self)
	UpdateStatusEffectIcons()

const STATUS_EFFECT_ICON = preload("res://Resources/StatusEffects/StatusEffectIcon.tscn")
func UpdateStatusEffectIcons():
	for i in conditionBox.get_children():
		i.free()
	if damagedPart : return
	for i in statusEffects:
		var statusEffectIcon : Control = STATUS_EFFECT_ICON.instantiate()
		conditionBox.add_child(statusEffectIcon)
		if i.sprite != null:
			var a : TextureRect = statusEffectIcon.get_child(0)
			a.texture = i.sprite

func TickStatusEffects():
	for i in statusEffects:
		i.OnTick(self)

func PlayAnimation(anim : StringName):
	if animationPlayer != null:
		if animationPlayer.has_animation(anim):
			animationPlayer.play(anim)

func IncreaseStage(amount : int):
	currentStage += amount
	if currentStage > maxStage: currentStage = maxStage
	SetPartSprites()
	if changeStageSFX != null:
		PlaySound(changeStageSFX)
	if playConstStreamSound != null:
		battleUI.SetConstantSFX(playConstStreamSound)
	var note = displayNoteAtStage.get(currentStage)
	if note != null:
		EmitNote.emit(note)

func SetStage(stage : int):
	currentStage = stage
	if playConstStreamSound != null:
		battleUI.SetConstantSFX(playConstStreamSound)
	SetPartSprites()

func IsAtMaxStage():
	return currentStage == maxStage

func GetEntity() -> Enemy:
	return enemy

func SetEnemy(e : Enemy):
	enemy = e

func GetAC():
	return enemy.GetAC() + acBonus

func GetMC():
	return enemy.GetMC()

func GetDamageResist(type : Global.DamageType):
	var i : float = enemy.GetDamageResist(type)
	return i

func GetAdvantage():
	return enemy.GetAdvantage()

func GetDisadvantage():
	return enemy.GetDisadvantage()

func GetTags() -> Array[String]:
	var fullTags : Array[String] = enemy.GetTags()
	fullTags.append_array(tags)
	return fullTags

func GetBodyPart():
	if disabled:
		return null
	else:
		return self

func PlaySound(sound : AudioStream, vol : float = 1):
	var audioPlayer = AudioStreamPlayer.new()
	add_child(audioPlayer)
	var stream = sound
	audioPlayer.volume_db = vol
	audioPlayer.pitch_scale = 1
	audioPlayer.stream = stream
	audioPlayer.play()
	await audioPlayer.finished
	audioPlayer.queue_free()

func IsDestroyed():
	if disabled || damagedPart:
		return true
	else:
		return false

func GetAdjacentParts():
	return adjacentParts

func GetStatusImmunities() -> Array[Global.StatusEffectTypes]:
	var a : Array[Global.StatusEffectTypes]
	a.append_array(GetEntity().GetStatusImmunities())
	a.append_array(limbImmunities)
	return a
