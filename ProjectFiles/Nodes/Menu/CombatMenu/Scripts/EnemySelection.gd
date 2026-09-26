class_name EnemySelection
extends Node

@onready var c : combat_menu = $".."

var highlightedParts : Array[EnemyBodyPart] = []
var confirmedParts : Array[EnemyBodyPart] = []
var selectedEnemys : Array[Enemy] = []
var enemyIndex : int = 0
var reqParts : int = 0

func BeginSelect(t : Action):
	if c.enemy.is_empty():
		return
	ClearHighlights()
	confirmedParts.clear()
	if t is Action_Hit:
		#print(t.actionName)
		SelectEnemy(c.enemy)
		var part = GetAlivePart(selectedEnemys[0].BattleUI.enemyParts)
		if part:
			highlightedParts = [part]
		#print(t.extraAttacks)
		reqParts = t.extraAttacks
		HighlightParts(true)

func ClearHighlights():
	for i in highlightedParts:
		i.DeselectPart()
	for i in confirmedParts:
		i.DeselectPart()
	highlightedParts.clear()

# -------------------------
# Direction Input
# -------------------------

func SelectUp(t : Action):
	if t is Action_Hit and highlightedParts.size() > 0:
		SelectPart(highlightedParts[0].upParts)

func SelectDown(t : Action):
	if t is Action_Hit and highlightedParts.size() > 0:
		SelectPart(highlightedParts[0].downParts)

func SelectLeft(t : Action):
	if t is Action_Hit and highlightedParts.size() > 0:
		SelectPart(highlightedParts[0].leftParts)

func SelectRight(t : Action):
	if t is Action_Hit and highlightedParts.size() > 0:
		SelectPart(highlightedParts[0].rightParts)

func SelectConfirm(t : Action):
	if t is Action_Hit and highlightedParts.size() > 0:
		confirmedParts.append_array(highlightedParts)

# -------------------------
# Selection Logic
# -------------------------

func SelectPart(pArray : Array[EnemyBodyPart]):
	if pArray.is_empty():
		return
	var newSelect = GetAlivePart(pArray)
	if newSelect == null:
		return
	HighlightParts(false)
	highlightedParts = [newSelect]
	HighlightParts(true)


func SelectEnemy(eArray : Array[Enemy]):
	if eArray.is_empty():
		return
	# Wrap index safely
	enemyIndex = clamp(enemyIndex, 0, eArray.size() - 1)
	var newSelect : Enemy = GetAliveEnemy(eArray)
	if newSelect == null:
		return
	selectedEnemys = [newSelect]

# -------------------------
# Helpers
# -------------------------

func GetAlivePart(pArray : Array[EnemyBodyPart]) -> EnemyBodyPart:
	for part in pArray:
		if part.GetBodyPart() != null && !part.IsDestroyed():
			return part
	return null


func GetAliveEnemy(eArray : Array[Enemy]) -> Enemy:
	for i in range(eArray.size()):
		var idx = (enemyIndex + i) % eArray.size()
		var e = eArray[idx]
		if e != null and not e.dead:
			enemyIndex = idx
			return e
	return null


# -------------------------
# Visuals
# -------------------------

func HighlightEnemy(enable : bool):
	for e in selectedEnemys:
		if e == null:
			continue
		for p in e.BattleUI.enemyParts:
			if enable:
				p.SelectPart()
			else:
				p.DeselectPart()

func HighlightParts(enable : bool):
	for part in highlightedParts:
		if part == null:
			continue
		if enable:
			part.SelectPart()
		else:
			part.DeselectPart()
	for part in confirmedParts:
		part.SelectPart()

# -------------------------
# UI Text
# -------------------------

func GetSelectionText(t : Action) -> String:
	if t is Action_Hit and highlightedParts.size() > 0:
		return highlightedParts[0].name
	return ""
