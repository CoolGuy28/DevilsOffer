class_name Action extends Resource
@export var actionName : String
@export var occultAction : bool
@export_multiline var smallDescription : String
signal ActionEnded()

var damage : Dictionary[Global.DamageType, int]
var healing : int = 0
var bloodDamage : int = 0
var statusEffect : Array[StatusEffect]

func DoAction(_user : Entity, _target):
	ActionEnded.emit()
	pass

func GetActionInfo(_user : Entity) -> String:
	
	return actionName + "\n" + smallDescription
