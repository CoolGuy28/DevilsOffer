class_name Skill_Button extends Control
@onready var panel: Panel = $Panel
var skill : Skill
var usable : bool
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func Setup(i: Skill, fontSize :int):
	skill = i
	if skill != null:
		rich_text_label.text = "[font_size=%d]%-20s" % [fontSize, skill.skillName]
	else:
		rich_text_label.text = "Empty"
	DeselectButton()

func SelectButton():
	panel.self_modulate = Color.WHITE

func EnabledButton():
	rich_text_label.self_modulate = Color.WHITE

func DisabledButton():
	rich_text_label.self_modulate = Color.DIM_GRAY

func SetButtonAvailable(player : Player, aCount : int, bCount : int):
	if skill is Skill_Action:
		if skill.CanUse(player):
			if skill.bonusAction && bCount > 0:
				usable = true
				EnabledButton()
			elif !skill.bonusAction && aCount > 0:
				usable = true
				EnabledButton()
			else : DisabledButton()
		else : DisabledButton()
	else : DisabledButton()

func DeselectButton():
	panel.self_modulate = Color.TRANSPARENT

func OnUse(player : Player):
	if skill is Skill_Action:
		skill.OnUse(player)

func GetAction():
	if skill is Skill_Action:
		return skill.action
	else:
		return null

func IsBonusAction():
	if skill is Skill_Action:
		return skill.bonusAction
	else:
		return null
