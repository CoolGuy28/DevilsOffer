class_name CombatMenuUI extends Sprite2D

@onready var healthSlider: HealthSlider = $CombatPanel/HealthSlider
@onready var bloodSlider: HealthSlider = $CombatPanel/BloodSlider

@onready var top_label: Panel = $TopLabel
@onready var topLabelText: RichTextLabel = $TopLabel/TextEdit
@onready var notes_container: VBoxContainer = $NotesContainer
const noteObj = preload("res://Menu/Components/Notes.tscn")
@onready var action_count: RichTextLabel = $CombatPanel/ActionCount
@onready var ba_count: RichTextLabel = $CombatPanel/BACount
@onready var action_info: RichTextLabel = $CombatPanel/ActionInfo

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
func ScreenShake(dmg : int):
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
		await get_tree().create_timer(0.8).timeout
		moveTween.kill()
	pass
