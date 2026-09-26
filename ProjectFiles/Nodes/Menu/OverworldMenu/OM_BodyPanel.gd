class_name OM_BodyPanel extends OM_Base

@export var bodyChoices: Array[SelectableText]
@export var limbDispArray : Array[PlayerBodypart_MenuUI]
@export var organDispArray : Array[PlayerBodypart_MenuUI]
var selectedBodyDisp : PlayerBodypart_MenuUI
@onready var body_animator: AnimationPlayer = $MarginContainer/BodyMenuControl/Body/BodyAnimator
@onready var info_display: InfoDisplayer = $MarginContainer/BodyMenuControl/InfoDisplay
@onready var healthSlider: HealthSlider = $MarginContainer/BodyMenuControl/HealthSlider
@onready var bloodSlider: HealthSlider = $MarginContainer/BodyMenuControl/BloodSlider

enum CurrentState { None, Header, Body }
var state : CurrentState = CurrentState.None
var headerState : int = 0 #0 = Skills, 1 = Body, 2 = Organs

func DisplayMenu():
	visible = true
	info_display.hide()
	for i in bodyChoices:
		i.DeselectButton()
	UpdateMenu()
	body_animator.play("Idle")

func UpdateMenu():
	for i in limbDispArray:
		i.SetTexture(overworld_menu.player.GetBody().bodyParts[i.bodypartNodeIndex])
		var sE = overworld_menu.player.GetBody().bodyParts[i.bodypartNodeIndex].GetStatusEffects()
		if sE != null:
			i.SetStatusEffectDisp(sE)
	for i in organDispArray:
		i.SetTexture(overworld_menu.player.GetBody().organs[i.bodypartNodeIndex])
	if !info_display.hidden:
		DisplayBodyPartInfo()
	healthSlider.IntialiseSlider(overworld_menu.GetPlayer().GetMaxHealth(), overworld_menu.GetPlayer().GetCurrentHealth())
	bloodSlider.IntialiseSlider(overworld_menu.GetPlayer().GetMaxBlood(), overworld_menu.GetPlayer().GetBloodLevel())

func CloseMenu():
	body_animator.stop()
	super()

func SetDefaultState(): 
	state = CurrentState.Header
	bodyChoices[headerState].SelectButton()

func SetNoneState():
	state = CurrentState.None

func InputNav(input : String):
	match state:
		CurrentState.Header: #Skills, Body, Organs
			match input:
				"up": 
					GameManager.PlayMenuSFX("Hover")
					headerState = NavigateMenu(-1, bodyChoices, headerState)
				"down": 
					GameManager.PlayMenuSFX("Hover")
					headerState = NavigateMenu(1, bodyChoices, headerState)
				"return":
					GameManager.PlayMenuSFX("Cancel")
					bodyChoices[headerState].DeselectButton()
					overworld_menu.SetInMenu(false)
				"select":
					GameManager.PlayMenuSFX("Select")
					if headerState == 0: #SelectBodyDisplay
						state = CurrentState.Body
						SelectLimb()
					elif headerState == 1: #SelectOrganDisplay
						state = CurrentState.Body
						SelectOrgan()
		CurrentState.Body: #Select Body Slots
			match input:
				"up": 
					GameManager.PlayMenuSFX("Hover")
					NavigateBody(2)
				"down": 
					GameManager.PlayMenuSFX("Hover")
					NavigateBody(-2)
				"left": 
					GameManager.PlayMenuSFX("Hover")
					NavigateBody(-1)
				"right": 
					GameManager.PlayMenuSFX("Hover")
					NavigateBody(1)
				"return":
					GameManager.PlayMenuSFX("Cancel")
					selectedBodyDisp.DeselectPart()
					state = CurrentState.Header
					info_display.hide()

func SelectLimb():
	if selectedBodyDisp == null || !limbDispArray.has(selectedBodyDisp): 
		selectedBodyDisp = limbDispArray[0]
		await get_tree().process_frame
		selectedBodyDisp.SelectPart()
		DisplayBodyPartInfo()

func SelectOrgan():
	if selectedBodyDisp == null || !organDispArray.has(selectedBodyDisp): 
		selectedBodyDisp = organDispArray[0]
		await get_tree().process_frame
		selectedBodyDisp.SelectPart()
		DisplayBodyPartInfo()

func SelectAllOrgans(b : bool):
	for i in organDispArray:
		if b : i.SelectPart()
		else : i.DeselectPart()

func SelectAllLimbs(b : bool):
	for i in limbDispArray:
		if b : i.SelectPart()
		else : i.DeselectPart()

func NavigateBody(dir : int):
	if selectedBodyDisp == null: 
		print("NoSelectedBodypart")
		return
	match dir:
		1: 
			if selectedBodyDisp.RightPart == null : return
			selectedBodyDisp.DeselectPart()
			selectedBodyDisp = selectedBodyDisp.RightPart
			selectedBodyDisp.SelectPart()
			DisplayBodyPartInfo()
		-1: 
			if selectedBodyDisp.LeftPart == null : return
			selectedBodyDisp.DeselectPart()
			selectedBodyDisp = selectedBodyDisp.LeftPart
			selectedBodyDisp.SelectPart()
			DisplayBodyPartInfo()
		2: 
			if selectedBodyDisp.UpPart == null : return
			selectedBodyDisp.DeselectPart()
			selectedBodyDisp = selectedBodyDisp.UpPart
			selectedBodyDisp.SelectPart()
			DisplayBodyPartInfo()
		-2: 
			if selectedBodyDisp.DownPart == null : return
			selectedBodyDisp.DeselectPart()
			selectedBodyDisp = selectedBodyDisp.DownPart
			selectedBodyDisp.SelectPart()
			DisplayBodyPartInfo()

func GetSelectedPart() -> Array[PlayerBodyPart]:
	return [selectedBodyDisp.bodyPart]

func DisplayBodyPartInfo():
	info_display.show()
	info_display.ClearContainer()
	info_display.AddText("[font_size=16]" + selectedBodyDisp.bodyPart.name)
	if selectedBodyDisp.bodyPart.IsDestroyed():
		info_display.AddText("[font_size=14]Destroyed")
	else:
		info_display.AddSlider(selectedBodyDisp.bodyPart.GetCurrentHP(), selectedBodyDisp.bodyPart.GetMaxHP())
	if selectedBodyDisp.bodyPart.vital:
		info_display.AddText("[font_size=14]Vital")
	if selectedBodyDisp.bodyPart.GetUnarmedAttack() != null:
		info_display.AddText("[font_size=14]" + selectedBodyDisp.bodyPart.GetUnarmedAttack().actionName)
	#	info_display.AddText("[font_size=12]" + selectedBodyDisp.bodyPart.GetUnarmedAttack().GetDamageStr(player.GetHitMod(0),player.GetStat(0)))
	if selectedBodyDisp.bodyPart.GetStatusEffects() != null:
		for i in selectedBodyDisp.bodyPart.GetStatusEffects():
			info_display.AddText("[font_size=12]" + i.GetName())
