class_name OverworldUI extends Node2D
@onready var text_box: Sprite2D = $TextBox
@onready var interaction_text: RichTextLabel = $TextBox/InteractionText
var currentTextDialogue : Array[String]
var currentTextIndex : int
var textVisSpeed : float = 0.02
var currentlyGrowing : bool

var skillCheckDC : int
var skillMod : int
signal close()

func _ready() -> void:
	text_box.hide()
	pass

func OpenTextBox(text : Array[String]):
	text_box.show()
	currentTextIndex = 0
	currentTextDialogue.clear()
	if text.size() > 0:
		currentTextDialogue = text.duplicate()
	ProcessDialogue()
	pass

func ProcessDialogue():
	#if interaction_text.visible_ratio < 0.9:
	#	interaction_text.visible_ratio = 1
	if currentTextDialogue.size() > currentTextIndex:
		interaction_text.text = currentTextDialogue[currentTextIndex]
		currentTextIndex += 1
		interaction_text.visible_ratio = 0
		await GrowText()
	else:
		CloseTextBox()
	pass

func GrowText():
	while interaction_text.visible_ratio < 1:
		interaction_text.visible_ratio += textVisSpeed
		await get_tree().process_frame

func CloseTextBox():
	text_box.hide()
	close.emit()

func OpenSkillCheck(skillDC : int, skillMods : int):
	skillCheckDC = skillDC
	skillMod = skillMods
	pass

func ProcessSkillCheck():
	var d20 = RollD20(false, false)
	print(str(d20) + " + " + str(skillMod))
	d20 += skillMod
	return d20

func RollD20(advantage : bool, disadvantage : bool):
	var d20 : int = randi_range(1, 20)
	if (advantage && !disadvantage):
		var newd20 : int = randi_range(1, 20)
		if newd20 > d20 : d20 = newd20
	if (disadvantage && !advantage):
		var newd20 : int = randi_range(1, 20)
		if newd20 < d20 : d20 = newd20
	return d20
