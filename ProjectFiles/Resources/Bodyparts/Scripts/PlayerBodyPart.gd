class_name PlayerBodyPart extends Node
@export var bodypartResource : PlayerBodyPart_Resource
@export_storage var currentHitPoints : int
@export var destroyed : bool
@export var destroyedStatChange : StatComponent_Player
@export var destroyedTexturePath : String = "Limbs/Destroyed/Arm_Destroyed"
@export var leftPart : bool
@export var vital : bool
signal PartDestroyed(s : String, v : bool)

func InitialisePartNode():
	if bodypartResource == null:
		destroyed = true
	else:
		currentHitPoints = bodypartResource.GetMaxHP()
	if currentHitPoints == 0:
		destroyed = true
	

func TakeDamage(dmg : int, dmgType : Global.DamageType = Global.DamageType.Slashing):
	if currentHitPoints <= 0 : return
	currentHitPoints -= dmg
	if currentHitPoints <= 0:
		DestroyPart(GetDamageDestroyMessage(dmgType))
	return dmg

func GetDamageDestroyMessage(dmgType : Global.DamageType):
	match dmgType:
		0: return "Your %s is crushed to death" % name
		1: return "Your %s is cut off" % name
		2: return "Your %s can't handle being stabbed" % name
		3: return "Your %s froze to death" % name
		4: return "Your %s becomes charred" % name
		5: return "Toxins destroy your %s" % name
		6: return "The nerves in %s stop working" % name
		_: return "Your % is removed" % name

func DestroyPart(destroyMessage : String):
	currentHitPoints = 0
	destroyed = true
	PartDestroyed.emit(destroyMessage, vital)

func HealPart(heal : int, regeneratePart : bool):
	if destroyed && regeneratePart:
		destroyed = false  
	if !destroyed:
		currentHitPoints += heal
		if currentHitPoints > bodypartResource.GetMaxHP() : currentHitPoints = bodypartResource.GetMaxHP()

func IsDestroyed():
	if destroyed == true || bodypartResource == null:
		return true
	else:
		return false

func GetTexture() -> Texture2D:
	var loadedTexture : Texture2D
	if !IsDestroyed():
		var path : String = bodypartResource.GetTexturePath()
		if bodypartResource.leftRightVarients:
			if leftPart == true: path += "_Left"
			else: path += "_Right"
		loadedTexture = load(path + ".png")
		if loadedTexture != null: return loadedTexture
	var p : String = "res://Sprites/UI/OverworldMenu/BodypartSprites/" + destroyedTexturePath
	if bodypartResource.leftRightVarients:
		if leftPart == true: p += "_Left"
		else: p += "_Right"
	loadedTexture = load(p + ".png")
	return loadedTexture

func GetMaxHP() -> int:
	if !IsDestroyed():
		return bodypartResource.GetMaxHP()
	else: 
		return 0

func GetCurrentHP() -> int:
	return currentHitPoints

func GetStatChanges():
	if IsDestroyed():
		return destroyedStatChange
	else:
		return null

func GetUnarmedAttack() -> Action:
	if !IsDestroyed():
		if bodypartResource is PlayerBodyPart_Arm_Resource:
			return bodypartResource.GetUnarmedAttack()
	return null

func GetStatusEffects():
	return null
