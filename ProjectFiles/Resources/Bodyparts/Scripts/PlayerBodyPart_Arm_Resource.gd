class_name PlayerBodyPart_Arm_Resource extends PlayerBodyPart_Resource
@export var unarmedAttack : Action

func GetUnarmedAttack() -> Action:
	if unarmedAttack != null:
		return unarmedAttack
	else : return null
