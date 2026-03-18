class_name EnemySelection extends Node
@onready var c : combat_menu = $".."
var selectedParts : Array[EnemyBodyPart]
var selectedEnemys : Array[Enemy]

func BeginSelect():
	if selectedParts.size() == 0:
		selectedParts.append(c.enemy[0].enemyParts[0])
	elif selectedParts[0].currentPartHealth <= 0:
		selectedParts.clear()
		selectedParts.append(c.enemy[0].enemyParts[0])
	HighlightParts(true)

func SelectUp(t : Action.TargetType):
	match t:
		Action.TargetType.HitAttack:
			SelectPart(selectedParts[0].upParts)

func SelectDown(t : Action.TargetType):
	match t:
		Action.TargetType.HitAttack:
			SelectPart(selectedParts[0].downParts)

func SelectLeft(t : Action.TargetType):
	match t:
		Action.TargetType.HitAttack:
			SelectPart(selectedParts[0].leftParts)

func SelectRight(t : Action.TargetType):
	match t:
		Action.TargetType.HitAttack:
			SelectPart(selectedParts[0].rightParts)

func SelectPart(pArray : Array[EnemyBodyPart]):
	if pArray.size() != 0:
		var newSelect = pArray[0]
		var i = 0
		while newSelect != null && newSelect.currentPartHealth <= 0:
			if i >= pArray.size() : return false 
			newSelect = pArray[i]
			i += 1
		HighlightParts(false)
		selectedParts.clear()
		selectedParts.append(newSelect)
		HighlightParts(true)
		return true
	pass

func HighlightParts(t : bool):
	for i in selectedParts:
		if t == true: i.SelectPart()
		else : i.DeselectPart()

func GetSelectionText():
	if selectedParts.size() == 1:
		return selectedParts[0].name
	else:
		return "null"
