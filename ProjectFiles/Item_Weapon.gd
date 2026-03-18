class_name Item_Weapon extends Item_Equippable
@export var attackAction : Action
@export var twoHanded : bool
@export var ranged : bool

func CreateUnarmed():
	var newAction := Action.new()
	newAction.SetAction("Unarmed Strike", 0, 0, 0, Global.DamageType.Bludgeoning, 1)
	attackAction = newAction

func GetAction():
	return attackAction
