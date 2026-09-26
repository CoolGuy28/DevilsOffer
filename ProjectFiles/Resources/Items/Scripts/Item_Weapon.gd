class_name Item_Weapon extends Item_Equippable
@export var attackAction : Action
enum WeaponType{Versatile, Light, TwoHanded}
@export var weaponType : WeaponType
@export var ranged : bool

func CreateUnarmed():
	var newAction := Action.new()
	newAction.SetAction("Unarmed Strike", 0, 0, 0, Global.DamageType.Bludgeoning, 1)
	attackAction = newAction

func GetAction():
	return attackAction
