class_name Action_Enemy extends Node
@export var action : Action
@export var attackTarget : String = ""
@export var bonusAction : bool
@export var freeAction : bool
@export var enabledPhases : Array[int] = [0]
@export var screenShakeTimer : float = 0.4
@export_category("Point Options")
@export var points : int = 10
@export var setPZeroOnUse : bool
var currentPoints : int
@export var pointGainPerTurn : int
@export_range(0,1.0) var pointGainChance : float = 1.0
@export var onlyAttackAtMaxStage : bool
@export var setStageAfterAttack : int = -1
@export_category("Text")
@export var critText : String = ""
@export var hitText : String = "The attack deals "
@export var missText : String = "You evade the attack"
@export var textAtPointThreshold : Dictionary[int, String]
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

func GetAction(currentPhase : int):
	if !enabledPhases.has(currentPhase):
		return null
	if GetParent().disabled:
		return null
	if points <= 0:
		return null
	return self
