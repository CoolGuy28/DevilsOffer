class_name combat_menu extends Control
@export var menuButtons : Array[ActionButton]
var selectedMenuButtonX : int
var selectedMenuButtonY : int
@onready var enemyBox: HBoxContainer = $Background/EnemyBox/EnemyBox
@onready var combatMenuUI: CombatMenuUI = $Background
@onready var enemy_selection: EnemySelection = $EnemySelection
enum CombatState{PlayerMenu, PlayerInv, PlayerAttack, SelectEnemy, EnemyAttack, EndCombat}
var state : CombatState
var currentActionCount : int
var currentBACount : int
var player : Player
var enemy : Array[Enemy]
var currentAction : Action
var BAAction : bool
var guard : bool
var dodge : bool
const MISS_SFX = preload("res://SFX/Actions/Miss/Miss.wav")
const TACKLEACTION = preload("uid://cf20vg137grg2")

func _ready() -> void:
	hide()
	set_process(false)
	pass

func GetSelectedButton():
	var index = selectedMenuButtonX + (selectedMenuButtonY * 4)
	return clamp(index, 0, menuButtons.size() - 1)

func GetInput(input : String):
	if state == CombatState.PlayerMenu:
		match input:
			"select":
				var btn = menuButtons[GetSelectedButton()]
				if !btn.buttonDisabled:
					if (btn.action and currentActionCount <= 0) or (btn.bonusAction and currentBACount <= 0):
						pass
					else: 
						btn.PressButton()
						GameManager.PlayMenuSFX("Hover")
			"left":
				SelectNewMenuButton(-1, false)
				GameManager.PlayMenuSFX("Hover")
			"right":
				SelectNewMenuButton(1, false)
				GameManager.PlayMenuSFX("Hover")
			"up":
				SelectNewMenuButton(-1, true)
				GameManager.PlayMenuSFX("Hover")
			"down":
				SelectNewMenuButton(1, true)
				GameManager.PlayMenuSFX("Hover")
			"shift":
				combatMenuUI.DisplayPlayerInfo(player)
			"shiftUndo":
				combatMenuUI.HidePlayerInfo()
	elif state == CombatState.PlayerInv:
		match input:
			"select":
				GameManager.PlayMenuSFX("Hover")
				SelectUsable()
			"return":
				GameManager.PlayMenuSFX("Hover")
				CloseUsablesInv()
			"up":
				GameManager.PlayMenuSFX("Hover")
				NavigateUsablesMenu(-1)
			"down":
				GameManager.PlayMenuSFX("Hover")
				NavigateUsablesMenu(1)

	elif state == CombatState.SelectEnemy:
		match input:
			"select":
				GameManager.PlayMenuSFX("Select")
				enemy_selection.SelectConfirm(currentAction)
				if enemy_selection.confirmedParts.size()-1 >= enemy_selection.reqParts:
					DoPlayerAttack()
			"return":
				GameManager.PlayMenuSFX("Cancel")
				enemy_selection.ClearHighlights()
				useDialogue = false
				OpenCombatMenu()
				combatMenuUI.HideTopLabel()
			"up":
				GameManager.PlayMenuSFX("Hover")
				enemy_selection.SelectUp(currentAction)
				DisplaySelectedPart()
			"down":
				GameManager.PlayMenuSFX("Hover")
				enemy_selection.SelectDown(currentAction)
				DisplaySelectedPart()
			"left":
				GameManager.PlayMenuSFX("Hover")
				enemy_selection.SelectLeft(currentAction)
				DisplaySelectedPart()
			"right":
				GameManager.PlayMenuSFX("Hover")
				enemy_selection.SelectRight(currentAction)
				DisplaySelectedPart()

func BeginCombat(p : Player, e : Enemy):
	show()
	skills_background.hide()
	player = p
	combatMenuUI.SetHealthUI(p)
	combatMenuUI.HidePlayerInfo()
	player.EmitNote.connect(combatMenuUI.DisplayNote)
	enemy.clear()
	enemy.append(e)
	for i in enemy:
		var enemyBattle : Enemy_BattleUI = i.GetEnemyBattle()
		enemyBattle.show()
		enemyBattle.reparent(enemyBox)
#		if i.beginBattleSFX != null:
#			i.CreateSFX(i.beginBattleSFX, 0.08, 0.7)
	BeginPlayerCombat()

func BeginPlayerCombat():
	await ActivatePlayerPassiveActions(Global.CombatActivation.OnBeginCombat)
	currentActionCount = player.GetAdjustedStatComponent().actionCount
	currentBACount = player.GetAdjustedStatComponent().bonusActionCount
	dodge = false
	guard = false
	show()
	OpenCombatMenu()

func OpenCombatMenu():
	state = CombatState.PlayerMenu
	EndCombatCheck()
	combatMenuUI.HideActionInfo()
	combatMenuUI.HideTopLabel()
	combatMenuUI.SetActionUI(currentActionCount, currentBACount)
	if (currentActionCount <= 0 && currentBACount <= 0):
		_on_end_turn_press()
	else:
		for i in range(menuButtons.size()):
			if (menuButtons[i].action and currentActionCount <= 0) or (menuButtons[i].bonusAction and currentBACount <= 0):
				menuButtons[i].DisableButton()
			else: 
				menuButtons[i].buttonDisabled = false
				menuButtons[i].DeselectButton() 
		menuButtons[GetSelectedButton()].SelectButton()
		SetMainActionDesc(GetSelectedButton())

func SelectNewMenuButton(i : int, vert : bool):
	menuButtons[GetSelectedButton()].DeselectButton()
	if vert:
		selectedMenuButtonY += i
		if selectedMenuButtonY < 0: selectedMenuButtonY += 3
		if selectedMenuButtonY >= 3: selectedMenuButtonY -= 3
	else:
		selectedMenuButtonX += i
		if selectedMenuButtonX < 0: selectedMenuButtonX += 4
		if selectedMenuButtonX >= 4: selectedMenuButtonX -= 4
	menuButtons[GetSelectedButton()].SelectButton()
	SetMainActionDesc(GetSelectedButton())

func SetMainActionDesc(i : int):
	match i:
		0:
			var _viewedAction := GetPlayerArmAction(false)
			combatMenuUI.SetActionInfo("[font_size=19]Attack\n[font_size=12]" + _viewedAction.GetActionInfo(player))
		1:
			var _viewedAction := GetPlayerArmAction(true)
			combatMenuUI.SetActionInfo("[font_size=19]OffHand\n[font_size=12]" + _viewedAction.GetActionInfo(player))
		2:
			combatMenuUI.SetActionInfo("[font_size=19]Skills")
		3, 7, 11:
			combatMenuUI.SetActionInfo("[font_size=19]End Turn")
		4:
			combatMenuUI.SetActionInfo("[font_size=19]Guard\n[font_size=12]Reduction\n" + str(player.GetGuardReduction()))
		5:
			combatMenuUI.SetActionInfo("[font_size=19]Dodge")
		6:
			combatMenuUI.SetActionInfo("[font_size=19]Items")
		8:
			combatMenuUI.SetActionInfo("[font_size=19]Talk")
		9:
			combatMenuUI.SetActionInfo("[font_size=19]Observe")
		10:
			combatMenuUI.SetActionInfo("[font_size=19]Flee\n[font_size=12]Chance\n" + str(GetFleeChance(player.GetSpeed(), enemy[0].GetSpeed())) + "%")
		_:
			combatMenuUI.SetActionInfo("")

func DisplaySelectedPart():
	combatMenuUI.SetTopLabelText(enemy_selection.GetSelectionText(currentAction))
	#		combatMenuUI.SetActionInfo("[font_size=19]Save Chance: ")
	if currentAction is Action_Hit:
			combatMenuUI.SetActionInfo("[font_size=19]Hit Chance: \n" + str(GetHitChance()) + "%")

func GetHitChance() -> int:
	var hitChance : float = currentAction.GetHitChance(player, enemy_selection.highlightedParts[0])
	hitChance = hitChance/20
	hitChance *= -1
	hitChance += 1
	hitChance *= 100
	return int(hitChance)

func RemoveActionCount():
	if BAAction:
		currentBACount -= 1
	else:
		currentActionCount -= 1

func BeginEnemyCombat():
	state = CombatState.EnemyAttack
	for e in enemy:
		if !e.dead:
			currentActionCount = e.GetAdjustedStatComponent().actionCount
			currentBACount = e.GetAdjustedStatComponent().bonusActionCount
			var usedLimbs : Array[EnemyBodyPart]
			var hasAttack = true
			while hasAttack && (currentActionCount > 0 || currentBACount > 0):
				var result: Action_Enemy = e.GetEnemyAction(currentActionCount, currentBACount, usedLimbs)
				if (result != null):
					BAAction = result.bonusAction
					var selectedEnemyPart: EnemyBodyPart = result.GetParent()
					currentAction = result.action
					result.UsedAction()
					usedLimbs.append(selectedEnemyPart)
					combatMenuUI.SetTopLabelText(currentAction.actionName)
					selectedEnemyPart.SelectPart()
					await get_tree().create_timer(0.6).timeout
					selectedEnemyPart.DeselectPart()
					await get_tree().create_timer(0.4).timeout
					var justAttacked : bool = false
					selectedEnemyPart.EmitNote.connect(combatMenuUI.DisplayNote)
					if result.onlyAttackAtMaxStage && !selectedEnemyPart.IsAtMaxStage():
						selectedEnemyPart.IncreaseStage(1)
					else:
						justAttacked = true
						if currentAction is Action_Hit : await EHitPAttack(e, result)
						if currentAction is Action_Utility : await EnemyUtilityAction(e)
					if !result.freeAction:
						RemoveActionCount()
					await get_tree().create_timer(0.2).timeout
					combatMenuUI.HideTopLabel()
					selectedEnemyPart.EmitNote.disconnect(combatMenuUI.DisplayNote)
					if justAttacked && result.setStageAfterAttack != -1:
						await get_tree().create_timer(0.2).timeout
						selectedEnemyPart.SetStage(result.setStageAfterAttack)
					await get_tree().create_timer(0.3).timeout
				else:
					hasAttack = false
		e.UpdateActionPoints()
	TickEnemyConditions()

func TickEnemyConditions():
	var eCheck = false
	for e in enemy:
		if !e.dead:
			if e.HasStatusEffects():
				eCheck = true
	if eCheck:
		await get_tree().create_timer(0.2).timeout
		combatMenuUI.SetTopLabelText("End Turn")
		for e in enemy:
			if !e.dead:
				if e.HasStatusEffects():
					eCheck = true
					e.TickStatusEffects()
		await get_tree().create_timer(1).timeout
		combatMenuUI.HideTopLabel()
	if EndCombatCheck() == false:
		BeginPlayerCombat()

func PlayerAttackCost():
	if selectedUsable != null:
		selectedUsable.OnUse(player)
		selectedUsable = null
		combatMenuUI.UpdateHealthUI(player)

##################
# Player Actions #
##################

func TargetEnemy(a : Action):
	currentAction = a
	state = CombatState.SelectEnemy
	enemy_selection.BeginSelect(currentAction)
	if currentAction != null:
		DisplaySelectedPart()
	pass

func DoPlayerAttack():
	enemy_selection.ClearHighlights()
	state = CombatState.PlayerAttack
	combatMenuUI.SetTopLabelText(currentAction.actionName)
	await get_tree().create_timer(0.4).timeout
	await PHitEAttack(enemy_selection.confirmedParts)
	combatMenuUI.SetHealthUI(player)
	combatMenuUI.HideTopLabel()
	RemoveActionCount()
	OpenCombatMenu()
	pass

func PHitEAttack(selected : Array[EnemyBodyPart]):
	var counter : int = 0
	await get_tree().create_timer(0.25).timeout
	for i in selected:
		var result = await currentAction.DoAction(player, i)
		var dmgPos : Vector2 = Vector2.ZERO
		if result["roll"] == 0:
			i.AttackMiss()
			await ActivatePlayerPassiveActions(Global.CombatActivation.OnPlayerCrit)
		else:
			if result["roll"] == 2:
				await ActivatePlayerPassiveActions(Global.CombatActivation.OnPlayerCrit)
			if currentAction.hitAnim.is_empty():
				i.CreateDamageEffect(Global.GetDamageType(currentAction.GetMainDType()), dmgPos)
			else:
				i.CreateDamageEffect(currentAction.hitAnim, dmgPos)
		for dmg in result["dmg"]:
			i.TakeDamage(result["dmg"][dmg], dmg, result["roll"] == 2)
		if result["heal"] > 0: player.Heal(result["heal"])
		if result["bld"] > 0: i.GetEntity().AdjustBlood(-result["bld"])
		for stFx in result["stFx"]:
			i.AddStatusEffect(stFx)
		combatMenuUI.UpdateHealthUI(player)
		counter += 1
		if counter < selected.size(): await get_tree().create_timer(currentAction.timeBtwExtHits).timeout
		else : await get_tree().create_timer(0.4).timeout

func PlayerUtilityAction(a : Action_Utility): 
	var focusString = a.focus
	var target = player
	if focusString != "":
		target = player.GetBody().GetBodyPart(focusString)
	var _result = await a.DoAction(player, target)
	combatMenuUI.UpdateHealthUI(player)
	RemoveActionCount()
	OpenCombatMenu()

func ActivatePlayerPassiveActions(activation : Global.CombatActivation):
	for item in player.GetPassiveItems():
		var action = item.GetPassiveAction(activation)
		if action != null:
			if action is Action_Hit || action is Action_Save:
				TargetEnemy(action)
			elif action is Action_Utility:
				PlayerUtilityAction(action)
	for skill in player.GetPassiveSkills():
		var action = skill.GetPassiveAction(activation)
		if action != null:
			if action is Action_Hit || action is Action_Save:
				TargetEnemy(action)
			elif action is Action_Utility:
				PlayerUtilityAction(action)

#################
# Enemy Actions #
################# 

func EHitPAttack(e : Enemy, eAction : Action_Enemy):
	var counter : int = 0
	await get_tree().create_timer(0.25).timeout
	for i in currentAction.extraAttacks + 1:
		var result = currentAction.DoAction(e, player)
		if result["roll"] == 0: # If the action missed
			combatMenuUI.DisplayNote(eAction.missText)
			await ActivatePlayerPassiveActions(Global.CombatActivation.OnEnemyMiss)
			combatMenuUI.UpdateHealthUI(player)
		else:# If the action hits
			if result["roll"] == 2: # If the action crits
				combatMenuUI.DisplayNote(eAction.critText)
			# Player Takes damage
			var pTarget = GetDamagePlayerBPTarget(eAction.attackTarget, currentAction.GetMainDType(), result["roll"] == 2)
			player.TakeDamage(result["dmg"], pTarget, eAction.hitText, guard)
			if result["heal"] > 0: e.Heal(result["heal"])
			if result["bld"] != 0: player.AdjustBlood(-result["bld"])
			for stFx in result["stFx"]:
				player.AddStatusEffect(stFx, pTarget)
			await ActivatePlayerPassiveActions(Global.CombatActivation.OnEnemyHit)
			combatMenuUI.UpdateHealthUI(player)
			await combatMenuUI.ScreenShake(10, eAction.screenShakeTimer)
		counter += 1
		if counter < currentAction.extraAttacks: await get_tree().create_timer(currentAction.timeBtwExtHits).timeout
		else : await get_tree().create_timer(0.4).timeout

func GetDamagePlayerBPTarget(eTarget : String, damageType : Global.DamageType, crit : bool) -> Array[PlayerBodyPart]:
	var damagedTarget : String = eTarget
	if damagedTarget == "" && crit:
		match damageType:
			2: damagedTarget = "Organ"
			5: damagedTarget = "Limb"
			6: damagedTarget = "Head"
			0,1,3,4,_: 
				if guard:
					damagedTarget = "Guard"
				else:
					damagedTarget = "Limb"
	return player.GetBody().GetBodyPart(damagedTarget)

func EnemyUtilityAction(e : Enemy): 
	await get_tree().create_timer(0.25).timeout
	if currentAction is Action_Utility:
		var focusString = currentAction.focus
		var target = focusString
		if focusString == "":
			target = e
		var _result = await currentAction.DoAction(e, target)
	await get_tree().create_timer(0.4).timeout


#func PlayerSaveAttack(e : Array[Enemy]):
	#var succeeded : Array[Enemy]
	#var failed : Array[Enemy]
	#var saveDC = currentAction.baseSaveDC + player.GetStat(currentAction.saveActionMod)
	#PlayerAttackCost()
	#for i in e:
		#var d20 : int = Global.RollD20(i.GetAdvantage(), i.GetDisadvantage())
		#d20 += i.GetStat(currentAction.statMod)
		#if d20 >= saveDC:
			#succeeded.append(i)
		#else:
			#failed.append(i)
	#for i in failed:
		#var damage : int = 0
		###Main Damage
		#if currentAction.IsDmgDieUsed():
			#damage = currentAction.GetActionDamage(player.GetStat(currentAction.statMod))
			#i.TakeDamage(damage, currentAction.damageType)
			#if currentAction.lifeSteal:
				#HealPlayer(damage, currentAction.healType)
		##Bonus Damage
		#if currentAction.IsBnsDieUsed():
			#damage = currentAction.GetActionBnsDamage()
			#i.TakeDamage(int(damage), currentAction.bnsDamageType)
		##Bleed Damage
		#if currentAction.IsBloodDieUsed():
			#damage = currentAction.GetActionBloodDamage()
			#i.AdjustBlood(-damage)
			#i.CreateDamageText("BLD" + str(damage), Color.DARK_RED)
			#combatMenuUI.DisplayNote("The enemy bleeds " + str(damage))
			#if currentAction.bloodLifeSteal:
				#player.AdjustBlood(damage)
		##Add StatusEffect
		#for statusEffect in currentAction.applyStatusChance:
			#if randi() % 100 + 1 <= currentAction.applyStatusChance.get(statusEffect):
				#i.AddStatusEffect(statusEffect)
#
##func EnemySaveAttack(e : Enemy, eAction : Action_Enemy):
	#var saveDC = currentAction.baseSaveDC + e.GetStat(currentAction.saveActionMod)
	#await get_tree().create_timer(0.4).timeout
	#if currentAction.GetCritSound() != null : PlaySound(currentAction.GetCritSound())
	#await player.OpenSaveThrow(saveDC, currentAction.statMod, dodge || player.GetAdvantage())
	#await get_tree().create_timer(0.8).timeout
	#var damagedLimb : Array[PlayerBodyPart] = player.player_body.GetBodyPart(GetDamagedPlayerTarget(eAction.attackTarget, false, currentAction.damageType))
	#if player.GetSkillCheckSuccess():
		#combatMenuUI.DisplayNote(eAction.missText)
		#if currentAction.halfDamageOnSucceed:
			#DamagePlayer(eAction, e.GetStat(currentAction.statMod), false, damagedLimb, 0.5)
		#else:
			#PlaySoundMiss(currentAction.GetMissSound())
	#else:
		#if eAction.critText != "":
			#combatMenuUI.DisplayNote(eAction.critText)
		#DamagePlayer(eAction, e.GetStat(currentAction.statMod), false, damagedLimb)
		##Bleed Damage
		#if currentAction.IsBloodDieUsed():
			#var dmg = currentAction.GetActionBloodDamage()
			#player.AdjustBlood(-dmg)
			#combatMenuUI.DisplayNote("You bleed " + str(dmg))
			#if currentAction.bloodLifeSteal:
				#e.AdjustBlood(dmg)
		##Add StatusEffect
		#for statusEffect in currentAction.applyStatusChance:
			#if randi() % 100 + 1 <= currentAction.applyStatusChance.get(statusEffect):
				#player.AddStatusEffect(statusEffect, damagedLimb)
#
#

func EndCombatCheck():
	var aliveEnemy : bool = false
	for e in enemy:
		if !e.dead:
			aliveEnemy = true
	if player.dead or !aliveEnemy:
		EndCombat()
		return true
	else:
		return false

func _on_attack_press() -> void:
	BAAction = false
	TargetEnemy(GetPlayerArmAction(false))
	pass

func _on_offhand_press() -> void:
	BAAction = true
	TargetEnemy(GetPlayerArmAction(true))
	pass

func GetPlayerArmAction(offhand : bool) -> Action:
	var returnAction : Action
	if offhand : 
		if player.GetOffHand() != null:
			returnAction = player.GetOffHand()
	else: 
		if player.GetMainHand() != null:
			returnAction = player.GetMainHand()
	if returnAction == null:
		returnAction = TACKLEACTION
	return returnAction

func _on_guard_press() -> void:
	guard = true
	currentBACount -= 1
	await ActivatePlayerPassiveActions(Global.CombatActivation.OnPlayerGuard)
	OpenCombatMenu()
	pass

func _on_dodge_press() -> void:
	dodge = true
	currentActionCount -= 1
	OpenCombatMenu()
	pass  # Replace with function body.

func _on_end_turn_press() -> void:
	state = CombatState.EnemyAttack
	await ActivatePlayerPassiveActions(Global.CombatActivation.OnEndTurn)
	TickPlayerConditions()
	pass # Replace with function body.

func TickPlayerConditions():
	if player.player_body.HasStatusEffects():
		#combatMenuUI.SetTopLabelText("End Turn")
		await get_tree().create_timer(0.4).timeout
		player.player_body.TickStatusEffects()
		combatMenuUI.UpdateHealthUI(player)
		await get_tree().create_timer(0.4).timeout
		combatMenuUI.HideTopLabel()
	BeginEnemyCombat()

@export var itemButtonScene : PackedScene
@export var skillButtonScene : PackedScene
@onready var skills_background: Sprite2D = $Background/CombatPanel/SkillsBackround
@onready var usableContainer: VBoxContainer = $Background/CombatPanel/SkillsBackround/UsablesContatiner
var usablesIndex : int = 0
var usableObjects : Array
var selectedUsable

func _on_skills_press() -> void:
	if player.GetUsableSkills().size() > 0:
		state = CombatState.PlayerInv
		skills_background.show()
		PopulateSkillUI(usableContainer, 6, 16)
		if usablesIndex >= usableObjects.size() : usablesIndex = 0
		usableObjects[usablesIndex].SelectButton()

func _on_items_press() -> void:
	if player.GetUsableItems():
		state = CombatState.PlayerInv
		skills_background.show()
		PopulateItemsUI(usableContainer, 6, 16)
		if usablesIndex >= usableObjects.size() : usablesIndex = 0
		usableObjects[usablesIndex].SelectButton()

func NavigateUsablesMenu(dir : int):
	if usableObjects.size() > 0:
		usableObjects[usablesIndex].DeselectButton()
		usablesIndex += dir
		if usablesIndex >= usableObjects.size(): usablesIndex = 0
		if usablesIndex < 0 : usablesIndex = usableObjects.size() -1
		usableObjects[usablesIndex].SelectButton()
		#invItemDescription.text = itemButtons[selectedInvIndex].item.description

func SelectUsable():
	selectedUsable = usableObjects[usablesIndex]
	var a : Action = selectedUsable.GetAction() as Action
	if a != null && selectedUsable.usable:
		BAAction = selectedUsable.IsBonusAction()
		skills_background.hide()
		if a is Action_Hit || a is Action_Save:
			TargetEnemy(a)
		elif a is Action_Utility:
			PlayerUtilityAction(a)

func CloseUsablesInv():
	skills_background.hide()
	selectedUsable = null
	state = CombatState.PlayerMenu

func PopulateSkillUI(invContainer : VBoxContainer, maxItems : int, fontSize : int):
	usableObjects.clear()
	ClearInventoryUI(invContainer)
	var shown := 0
	for item in player.GetUsableSkills():
		if shown >= maxItems:
			break
		# Instance the ItemButton scene
		var btn : Skill_Button = skillButtonScene.instantiate()
		invContainer.add_child(btn)
		# SET DATA ON THE BUTTON
		btn.Setup(item, fontSize)
		usableObjects.append(btn)
		btn.SetButtonAvailable(player, currentActionCount, currentBACount)
		shown += 1
			
	if usablesIndex > usableObjects.size():
		usablesIndex = 0

func PopulateItemsUI(invContainer : VBoxContainer, maxItems : int, fontSize : int):
	usableObjects.clear()
	ClearInventoryUI(invContainer)
	var shown := 0
	var usableItems : Dictionary[Item, int] = player.GetUsableItems()
	for item in usableItems:
		if shown >= maxItems:
			break
		# Instance the ItemButton scene
		var btn : Item_Button = itemButtonScene.instantiate()
		invContainer.add_child(btn)
		# SET DATA ON THE BUTTON
		btn.Setup(item, usableItems[item], fontSize)
		usableObjects.append(btn)
		btn.SetButtonAvailable(player, currentActionCount, currentBACount)
		shown += 1
			
	if usablesIndex > usableObjects.size():
		usablesIndex = 0

func ClearInventoryUI(invContainer : VBoxContainer):
	for child in invContainer.get_children():
		child.queue_free()
	usableObjects.clear()

var useDialogue
func _on_talk_press() -> void:
	pass

func PlaySoundDamage(soundPath : AudioStream, damageType : Global.DamageType):
	if soundPath == null:
		PlaySoundPath(Global.GetDamageTypeAudio(damageType))
	else:
		PlaySound(soundPath)

func PlaySoundMiss(soundPath : AudioStream):
	if soundPath == null:
		PlaySound(MISS_SFX)
	else:
		PlaySound(soundPath)

func PlaySound(sound : AudioStream, vol : float = 1):
	var audioPlayer = AudioStreamPlayer.new()
	add_child(audioPlayer)
	var stream = sound
	audioPlayer.volume_db = linear_to_db(vol)
	audioPlayer.pitch_scale = 1
	audioPlayer.stream = stream
	audioPlayer.play()
	await audioPlayer.finished
	audioPlayer.queue_free()

func PlaySoundPath(soundPath : String,  vol : float = 1):
	var audioPlayer = AudioStreamPlayer.new()
	add_child(audioPlayer)
	var stream = load(soundPath)
	audioPlayer.volume_db = vol
	audioPlayer.pitch_scale = 1
	audioPlayer.stream = stream
	audioPlayer.play()
	await audioPlayer.finished
	audioPlayer.queue_free()

const fleeBonus : float = 0.5
func GetFleeChance(player_speed: float, enemy_speed: float) -> float:
	var pSpeed = player_speed + fleeBonus
	var total = pSpeed + enemy_speed
	if total <= 0:
		return 50
	var chance = 100.0 * pSpeed / total
	return clamp(chance, 0.0, 90.0)

func _on_flee_press() -> void:
	if currentActionCount <= 0:
		return
	if enemy.size() == 0:
		return
	BAAction = false
	RemoveActionCount()
	var fleeScore = randi() % 100 + 1
	var fleeChance = GetFleeChance(player.GetSpeed(), enemy[0].GetSpeed())
	print("Flee Score: " + str(fleeScore))
	if fleeScore <= fleeChance:
		EndCombat()
		print("Escaped")
	else:
		combatMenuUI.DisplayNote("You fail to escape")
		OpenCombatMenu()

signal CombatFinished()
func EndCombat():
	state = CombatState.EndCombat
	player.EmitNote.disconnect(combatMenuUI.DisplayNote)
	await get_tree().create_timer(1.0).timeout
	CombatFinished.emit()
	for i in enemy:
		i.GetEnemyBattle().reparent(i)
		i.GetEnemyBattle().hide()
	player.OpenOverworld()
	enemy.clear()
	enemy_selection.ClearHighlights()
	currentAction = null
	GameManager.SetPause(false)
	hide()
	pass
