class_name Action_Save extends Action
@export var baseSaveDC : int = 10
@export var abilityMod : int = 2
@export var saveAbility : int = 2

@export var savedAction : Array[ActionResource]
@export var failedAction : Array[ActionResource]

func DoAction(_user : Entity, _target):
	pass
