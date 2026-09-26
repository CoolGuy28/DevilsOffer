class_name CombatMenuUI extends TextureRect

@onready var healthSlider: HealthSlider = $CombatPanel/HealthSlider
@onready var bloodSlider: HealthSlider = $CombatPanel/BloodSlider

@onready var top_label: Panel = $TopLabel
@onready var topLabelText: RichTextLabel = $TopLabel/TextEdit
@onready var notes_container: VBoxContainer = $NotesContainer
const noteObj = preload("res://Nodes/Menu/Components/Notes.tscn")
@onready var action_count: RichTextLabel = $CombatPanel/ActionCount
@onready var ba_count: RichTextLabel = $CombatPanel/BACount
@onready var action_info: RichTextLabel = $CombatPanel/ActionInfo

@onready var playerInfo: Panel = $Info
@onready var state: RichTextLabel = $Info/VBoxContainer/STATE/RichTextLabel
@onready var ac: RichTextLabel = $Info/VBoxContainer/AC/RichTextLabel2
@onready var mc: RichTextLabel = $Info/VBoxContainer/MC/RichTextLabel3
@onready var Str: RichTextLabel = $Info/VBoxContainer2/STR/RichTextLabel2
@onready var Dex: RichTextLabel = $Info/VBoxContainer2/DEX/RichTextLabel2
@onready var Int: RichTextLabel = $Info/VBoxContainer2/INT/RichTextLabel2
@onready var Wis: RichTextLabel = $Info/VBoxContainer2/WIS/RichTextLabel2
@onready var body_control: Control = $Info/BodyControl
const STATUS_EFFECT_ICON = preload("uid://cq2hpef781674")

signal finishedScreenShake()

func SetHealthUI(p : Player):
	healthSlider.IntialiseSlider(p.GetMaxHealth(), p.GetCurrentHealth())
	bloodSlider.IntialiseSlider(p.GetMaxBlood(), p.GetBloodLevel())

func UpdateHealthUI(p : Player):
	healthSlider.UpdateSliderSlide(p.GetCurrentHealth())
	bloodSlider.UpdateSliderSlide(p.GetBloodLevel())

func SetActionUI(actionCount : int, bonusACount : int):
	action_count.text = str(actionCount)
	ba_count.text = str(bonusACount)

func SetActionInfo(text : String):
	action_info.show()
	action_info.text = text

func HideActionInfo():
	action_info.hide()

func SetTopLabelText(t : String):
	top_label.show()
	topLabelText.text = t

func HideTopLabel():
	top_label.hide()

func DisplayNote(note : String):
	var newNote: CombatNoteText = noteObj.instantiate()
	notes_container.add_child(newNote)
	newNote.SetNoteText(note)
	pass

var moveTween: Tween
func ScreenShake(dmg : int, timer : float):
	if dmg > 0:
		var sIntensity = 0
		var sTime = 0
		if dmg > 30:
			sIntensity = 18
			sTime = 0.13
		elif dmg > 15:
			sIntensity = 13
			sTime = 0.15
		elif dmg > 8:
			sIntensity = 10
			sTime = 0.16
		else:
			sIntensity = 4
			sTime = 0.18
		moveTween = create_tween()
		moveTween.set_loops() # infinite loop
		
		moveTween.tween_property(self, "position:x", sIntensity, sTime) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)
			
		moveTween.tween_property(self, "position:x", -sIntensity, sTime) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)
		await get_tree().create_timer(timer).timeout
	moveTween.kill()
	finishedScreenShake.emit()
	pass

func DisplayPlayerInfo(p : Player):
	playerInfo.visible = true
	state.text = "[font_size=15]BNS[font_size=30]\n" + Global.GetIntAsStr(p.GetStateBonus())
	ac.text = "[font_size=15]AC[font_size=30]\n" + str(p.GetAC())
	mc.text = "[font_size=15]MC[font_size=30]\n" + str(p.GetMC())
	Str.text = "[font_size=25]" + Global.GetIntAsStr(p.GetStat(0))
	Dex.text = "[font_size=25]" + Global.GetIntAsStr(p.GetStat(1))
	Int.text = "[font_size=25]" + Global.GetIntAsStr(p.GetStat(2))
	Wis.text = "[font_size=25]" + Global.GetIntAsStr(p.GetStat(3))
	for i in range(6):
		var limb : PlayerBodyLimb = p.GetBody().bodyParts[i]
		var t : TextureRect = body_control.get_child(i)
		var sb : HBoxContainer = t.get_child(1)
		for statusGraphic in sb.get_children():
			statusGraphic.queue_free()
		if limb.IsDestroyed():
			t.visible = false
		else:
			t.visible = true
			var inner : TextureRect = t.get_child(0)
			var r : float = 1.0 - (float(limb.GetCurrentHP()) / limb.GetMaxHP())
			inner.modulate = Color.from_rgba8(int(r * 100),0,0,255)
			for statusEffect in limb.statusEffects:
				var statusIcon = STATUS_EFFECT_ICON.instantiate()
				statusIcon.get_child(0).texture = statusEffect.sprite
				sb.add_child(statusIcon)

func HidePlayerInfo():
	playerInfo.visible = false
