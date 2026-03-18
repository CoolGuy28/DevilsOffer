class_name EnemyBodyPart extends Sprite2D
@export var maxPartHealth : int
@export var dmgResist: Dictionary[Global.DamageType, float]
@export var lethalPart : bool
@export var acBonus : int
@onready var conditionBox: HBoxContainer = $ConditionBox
@export var destroyedStatChange : StatComponent
@export var upParts : Array[EnemyBodyPart]
@export var leftParts : Array[EnemyBodyPart]
@export var rightParts : Array[EnemyBodyPart]
@export var downParts : Array[EnemyBodyPart]
@export var partMoveSpd : float
@export var movementBounds : Vector2
@export var movePosition : bool
@export var baseSprite : Texture2D
@export var damagedSprite : Texture2D
@export var damagedPart : bool
var statusEffects : Array[StatusEffect_Limb]
var currentPartHealth : int
var enemy : Enemy
const damageTextScene = preload("res://Entity/Enemy/Damage_Text.tscn")

func _ready() -> void:
	currentPartHealth = maxPartHealth
	InitialisePart()
	pass 

func InitialisePart():
	if damagedPart == true:
		texture = damagedSprite
	else:
		texture = baseSprite
	if partMoveSpd > 0:
		if movePosition:
			MovePartPos()
		else:
			MovePartRot()

var moveTween: Tween
func MovePartRot():
	moveTween = create_tween()
	moveTween.set_loops() # infinite loop
	
	moveTween.tween_property(self, "rotation_degrees", movementBounds.y, partMoveSpd) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
		
	moveTween.tween_property(self, "rotation_degrees", movementBounds.x, partMoveSpd) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

func MovePartPos():
	moveTween = create_tween()
	moveTween.set_loops() # infinite loop

	moveTween.tween_property(self, "position", Vector2(position.x, movementBounds.y), partMoveSpd) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

	moveTween.tween_property(self, "position", Vector2(position.x, movementBounds.x), partMoveSpd) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

var damage_tween : Tween = null

func SelectPart():
	if damage_tween and damage_tween.is_running():
		damage_tween.kill()
	self_modulate = Color(2, 2, 2)


func DeselectPart():
	self_modulate = Color(1, 1, 1)


func TakeDamage(damage : int, damageType : Global.DamageType, crit : bool = false):
	if currentPartHealth <= 0 : return
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
	CreateDamageText(textString, Global.GetDamageColor(damageType))

	# Flash BodyPart Red When Damaged
	self_modulate = Color.FIREBRICK

	# Kill old tween if it exists
	if damage_tween and damage_tween.is_running():
		damage_tween.kill()

	damage_tween = create_tween()
	damage_tween.tween_property(self, "self_modulate", Color.WHITE, 1.5)

	# Decrease Part Health
	currentPartHealth -= dmg
	if currentPartHealth <= 0:
		KillPart()
	return dmg

func Heal(heal : int):
	var textString = ""
	var h : int = heal
	textString += str(h)
	CreateDamageText(textString, Color.GREEN)

	# Flash BodyPart Red When Damaged
	self_modulate = Color.DARK_GREEN

	# Kill old tween if it exists
	if damage_tween and damage_tween.is_running():
		damage_tween.kill()

	damage_tween = create_tween()
	damage_tween.tween_property(self, "self_modulate", Color.WHITE, 1.5)

	# Decrease Part Health
	currentPartHealth += h
	if currentPartHealth > maxPartHealth: currentPartHealth = maxPartHealth
	return h

const textDist : float = 14
func CreateDamageText(textString : String, colour : Color):
	var damage_label: DamageText = damageTextScene.instantiate()
	add_child(damage_label)
	damage_label.position = position + Vector2(randfn(-textDist,textDist), randfn(-textDist,textDist))
	damage_label.set_damage_text(textString, colour)

func KillPart():
	if (lethalPart):
		enemy.KillEnemy()
	damagedPart = true
	if damagedSprite != null:
		texture = damagedSprite
	statusEffects.clear()
	UpdateStatusEffectIcons()
	enemy.SetAdjustedStatComponent()

func AttackMiss():
	var damage_label: DamageText = damageTextScene.instantiate()
	add_child(damage_label)
	damage_label.position = Vector2(randfn(-textDist,textDist), randfn(-textDist,textDist))
	damage_label.set_damage_text("Miss")

func AddStatusEffect(statusEffect : StatusEffect_Limb):
	if !statusEffects.has(statusEffect):
		statusEffects.append(statusEffect)
		statusEffect.OnGain(self)
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
			var a : Sprite2D = statusEffectIcon.get_child(0)
			a.texture = i.sprite

func TickStatusEffects():
	for i in statusEffects:
		i.OnTick(self)

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
	var r = dmgResist.get(type, i)
	if r < 0.0:
		r = 0.0
	elif r > 1.0:
		r = 2.0
	return r

func GetAdvantage():
	return enemy.GetAdvantage()

func GetDisadvantage():
	return enemy.GetDisadvantage()
