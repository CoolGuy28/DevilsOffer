class_name Action extends Resource
@export var actionName : String
@export var occultAction : bool
signal ActionEnded()

var damage : Dictionary[Global.DamageType, int]
var healing : int = 0
var bloodDamage : int = 0
var statusEffect : Array[StatusEffect]

func DoAction(_user : Entity, _target):
	ActionEnded.emit()
	pass
