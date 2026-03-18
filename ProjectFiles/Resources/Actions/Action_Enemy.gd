class_name Action_Enemy extends Node
@export var action : Action
@export var attackTarget : String = ""
@export var bonusAction : bool
@export var freeAction : bool
@export var points : int = 10
@export var setPZeroOnUse : bool
var currentPoints : int
@export var pointGainPerTurn : int
@export_range(0,1.0) var pointGainChance : float = 1.0
@export var critText : String = ""
@export var hitText : String = "The attack deals "
@export var missText : String = "You evade the attack"
func _ready() -> void: currentPoints = points

func GetParent() -> EnemyBodyPart: 
	return self.get_parent()

func UpdatePoints():
	if pointGainPerTurn != 0:
		if pointGainChance != 1.0:
			if randf() > pointGainChance:
				return
		currentPoints += pointGainPerTurn

func UsedAction():
	if setPZeroOnUse || freeAction:
		currentPoints = 0
	else:
		currentPoints = points
