class_name Entity extends CharacterBody2D
var direction = Vector2.ZERO
var currentMoveSpeed : float = 1
@export var sprintSpeed : float = 1.6
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var baseStats: StatComponent
@export var adjustedStats: StatComponent
var maxBloodLevel : int = 100
var currentBloodLevel : int

func _ready() -> void:
	SetAdjustedStatComponent()
	currentBloodLevel = maxBloodLevel
	currentMoveSpeed = adjustedStats.GetMoveSpeed()

func _physics_process(_delta):
	move_and_slide()
	UpdateAnimation()

func Movement(moveDir: Vector2, sprint: bool):
	if sprint:
		currentMoveSpeed = adjustedStats.GetMoveSpeed() * sprintSpeed
	else:
		currentMoveSpeed = adjustedStats.GetMoveSpeed()

	if moveDir != Vector2.ZERO:
		direction = moveDir.normalized()
		velocity = direction * currentMoveSpeed * 200
	else:
		velocity = Vector2.ZERO

func AdjustBlood(bloodAdj : int):
	currentBloodLevel += bloodAdj
	if currentBloodLevel > maxBloodLevel:
		var a = currentBloodLevel - maxBloodLevel
		currentBloodLevel = maxBloodLevel
		Heal(a, "All")
	elif currentBloodLevel < 0:
		var a = currentBloodLevel * -1
		currentBloodLevel = 0
		TakeDamage(a, Global.DamageType.Bleed)

func TakeDamage(_damage : int, _dmgType : Global.DamageType):
	return 0

func Heal(heal : int, _type : String):
	var h : int = heal
	if currentBloodLevel != maxBloodLevel : 
		var blood = float(currentBloodLevel) / float(maxBloodLevel)
		h = int(h/blood)
	if h < 0 : h = 0
	return h

func AddStatusEffect(_statusEffect : StatusEffect, _target): pass

func UpdateAnimation():
	if direction.y > 0:
		sprite.animation = "Down"
	elif direction.y < 0:
		sprite.animation = "Up"
	elif direction.x > 0:
		sprite.animation = "Right"
	elif direction.x < 0:
		sprite.animation = "Left"
	# If we are not actually moving (eg. walking into wall)
	if velocity.length() < 0.1:
		sprite.pause()
		sprite.frame = 0
		return
	sprite.play()

func SetAdjustedStatComponent():
	adjustedStats.CopyStatComponent(baseStats)
	adjustedStats.UpdateValues()

func GetBaseStatComponent():
	return baseStats

func GetAdjustedStatComponent():
	return adjustedStats

func GetStat(i : int):
	return adjustedStats.GetStat(i)

func GetCritStat():
	return adjustedStats.GetStat(3)

func GetHitMod(i : int):
	return adjustedStats.GetStat(i) + adjustedStats.GetSkillBonus()

func GetDamageMod(i : int):
	return adjustedStats.GetStat(i)

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
