class_name PlayerBodyPart extends Node
@export var maxHitPoints : int
var currentHitPoints : int
var destroyed : bool
var destroyedStatChange : StatComponent_Player

func TakeDamage(dmg : int, _dmgType : Global.DamageType):
	if currentHitPoints <= 0 : return
	currentHitPoints -= dmg
	if currentHitPoints <= 0:
		DestroyPart()
	return dmg

func DestroyPart():
	currentHitPoints = 0
	destroyed = true

func HealPart(heal : int, regeneratePart : bool):
	if destroyed && regeneratePart:
		destroyed = false  
	if !destroyed:
		currentHitPoints += heal
		if currentHitPoints > maxHitPoints : currentHitPoints = maxHitPoints
