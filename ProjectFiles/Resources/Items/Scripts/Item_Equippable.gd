class_name Item_Equippable extends Item
@export var equippedStats : StatComponent_Player
@export var equippableValue : int = 1

@export var activation : Global.CombatActivation
@export var action : Action

@export_multiline var shortDescription : String

func GetPassiveAction(a : Global.CombatActivation):
	if action == null: return null
	if a == activation:
		return action
	return null

func GetEquippableValue() -> int :
	return equippableValue

func GetDescription(_short : bool = false):
	if _short:
		return shortDescription
	else:
		return description
