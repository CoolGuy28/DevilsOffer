class_name Entity extends CharacterBody2D
var pauseMovement : bool
var direction = Vector2.ZERO
var currentMoveSpeed : float = 1
@onready var animatedSprite: EntityAnimController = $AnimatedSprite2D
@onready var audioNode: AudioNode = $AudioNode
@export var baseStats: StatComponent
@export var adjustedStats: StatComponent
@export var statusImmunities : Array[Global.StatusEffectTypes]
@export var tags : Array[String]
@export var defaultDir : Vector2 = Vector2(0, 1)
var maxBloodLevel : int = 100
@export_storage var currentBloodLevel : int
@export_storage var firstLoad : bool = true

func _ready() -> void:
	SetAdjustedStatComponent()
	SetDirection(defaultDir)
	if firstLoad :
		currentBloodLevel = GetMaxBlood()
		firstLoad = false

func _physics_process(_delta):
	if GameManager.GetPause() || pauseMovement:
		velocity = Vector2.ZERO
		UpdateMovingAnimation()
	else:
		move_and_slide()

func Movement(moveDir: Vector2, sprint: bool):
	currentMoveSpeed = adjustedStats.GetMoveSpeed(sprint)
	if moveDir != Vector2.ZERO:
		direction = moveDir
		velocity = direction.normalized() * currentMoveSpeed * 150
	else:
		velocity = Vector2.ZERO
	UpdateMovingAnimation(sprint)

func SetDirection(dir : Vector2):
	if pauseMovement : return
	direction = dir.normalized()
	UpdateMovingAnimation()

func UpdateMovingAnimation(sprint : bool = false):
	if adjustedStats.legs <= 0:
		animatedSprite.SetCrawlAnim(direction, velocity)
	else:
		if sprint:
			animatedSprite.SetSprintAnim(direction, velocity)
		else:
			animatedSprite.SetMovementAnim(direction, velocity)

func PlayAnimation(anim : String, _pauseMovement : bool = true):
	if pauseMovement:
		PauseMovement(true)
	animatedSprite.SetAnimation(anim)

func PauseMovement(p : bool):
	pauseMovement = p

func AdjustBlood(bloodAdj : int, spawnsBlood : bool = true):
	if bloodAdj < -6 && spawnsBlood:
		var blood : Bloodstain = Global.BLOODSTAIN.instantiate()
		blood.position = position + Vector2(randf_range(-1.5,1.5),randf_range(-1.5,1.5))
		SceneSwitcher.openScene.add_child(blood)
	currentBloodLevel += bloodAdj
	if currentBloodLevel > GetMaxBlood():
		var a = currentBloodLevel - GetMaxBlood()
		currentBloodLevel = GetMaxBlood()
		Heal(a)
	elif currentBloodLevel < 0:
		var a = currentBloodLevel * -1
		currentBloodLevel = 0
		TakeDamage({Global.DamageType.Bleed : a})

func TakeDamage(_damage : Dictionary[Global.DamageType, int]):
	return 0

func Heal(heal : int, _type : Array = []):
	var h : int = heal
	if currentBloodLevel != 100 : 
		var blood = float(currentBloodLevel) / float(100)
		if blood < 0.25 : blood = 0.25
		h = ceili(h*blood)
	if h < 0 : h = 0
	return h

func AddStatusEffect(_statusEffect : StatusEffect, _target): pass

func RemoveStatusEffect(_statusEffectTag : String, _target): pass

func AdjustExhaustion(i : int):
	adjustedStats.exhaustion = AdjustExhaustion(i)
	if adjustedStats.GetExhaustion() >= 6 : TakeDamage({Global.DamageType.Bleed : 999})

func PlaySFX(s : String, p : float = 1.0):
	audioNode.PlaySFX(s, p)

func SetAdjustedStatComponent():
	adjustedStats.CopyStatComponent(baseStats)
	adjustedStats.UpdateValues()
	SetCurrentValues()

func SetCurrentValues():
	currentMoveSpeed = adjustedStats.GetMoveSpeed()
	if adjustedStats.legs <= 0:
		UpdateMovingAnimation()

func GetBaseStatComponent():
	return baseStats

func GetAdjustedStatComponent():
	return adjustedStats

func GetStat(i : int):
	return adjustedStats.GetStat(i)

func GetStateBonus():
	return adjustedStats.GetStateBonus()

func GetExhaustion():
	return adjustedStats.GetExhaustion()

func GetCritStat():
	return adjustedStats.GetStat(3)

func GetHitMod(i : int, _occultAction : bool):
	return adjustedStats.GetStat(i) + adjustedStats.GetStateBonus()

func GetDamageMod(i : int):
	return adjustedStats.GetStat(i)

func GetSaveMod(i : int):
	return adjustedStats.GetStat(i) + adjustedStats.GetStateBonus()

func GetSaveDCMod(i : int):
	return adjustedStats.GetStat(i) + adjustedStats.GetStateBonus()

func AdjustOutgoingDamage(i : Dictionary[Global.DamageType, int]):
	var newDamage = i.duplicate()
	return newDamage

func GetAC():
	return adjustedStats.GetAC()

func GetMC():
	return adjustedStats.GetMC()

func GetBloodLevel():
	return currentBloodLevel

func GetMaxBlood():
	return maxBloodLevel

func GetDamageResist(type : Global.DamageType):
	return adjustedStats.GetDamageResist(type)

func GetAdvantage():
	return adjustedStats.GetAdvantage()

func GetDisadvantage():
	return adjustedStats.GetDisadvantage()

func GetTags() -> Array[String]:
	return tags

func GetSpeed() -> float:
	return GetAdjustedStatComponent().moveSpeed

func GetStatusImmunities() -> Array[Global.StatusEffectTypes]:
	return statusImmunities
