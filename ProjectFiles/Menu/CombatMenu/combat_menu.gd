class_name combat_menu extends Control
@export var menuButtons : Array[ActionButton]
var selectedMenuButtonX : int
var selectedMenuButtonY : int
@onready var enemyBox: Node2D = $Background/EnemyBox
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

func _ready() -> void:
	hide()
	set_process(false)
	pass

func GetInput(input : String):
	if state == CombatState.PlayerMenu:
		match input:
			"select":
				if !menuButtons[GetSelectedButton()].buttonDisabled:
					if menuButtons[GetSelectedButton()].action && currentActionCount <= 0 || menuButtons[GetSelectedButton()].bonusAction && currentBACount <= 0:
						pass
					else: menuButtons[GetSelectedButton()].PressButton()
			"left":
				SelectNewMenuButton(-1, false)
			"right":
				SelectNewMenuButton(1, false)
			"up":
				SelectNewMenuButton(-1, true)
			"down":
				SelectNewMenuButton(1, true)
	elif state == CombatState.PlayerInv:
		match input:
			"select":
				SelectUsable()
			"return":
				CloseUsablesInv()
			"up":
				NavigateUsablesMenu(-1)
			"down":
				NavigateUsablesMenu(1)
	elif state == CombatState.SelectEnemy:
		match input:
			"select":
				enemy_selection.HighlightParts(false)
				DoPlayerAttack()
				combatMenuUI.HideTopLabel()
			"return":
				enemy_selection.HighlightParts(false)
				OpenCombatMenu()
				combatMenuUI.HideTopLabel()
			"up":
				enemy_selection.SelectUp(currentAction.targetType)
				DisplaySelectedPart()
			"down":
				enemy_selection.SelectDown(currentAction.targetType)
				DisplaySelectedPart()
			"left":
				enemy_selection.SelectLeft(currentAction.targetType)
				DisplaySelectedPart()
			"right":
				enemy_selection.SelectRight(currentAction.targetType)
				DisplaySelectedPart()
	pass

func BeginCombat(p : Player, e : Enemy):
	show()
	usableContainer.hide()
	player = p
	combatMenuUI.SetHealthUI(p)
	enemy.clear()
	enemy.append(e)
	show()
	for i in enemyBox.get_children():
		i.queue_free()
	for i in enemy:
		var enemyBattle : Node2D = i.GetEnemyBattle()
		enemyBattle.show()
		enemyBattle.reparent(enemyBox)
		enemyBattle.transform.origin = Vector2.ZERO
	BeginPlayerCombat()
	pass

func BeginPlayerCombat():
	currentActionCount = player.GetAdjustedStatComponent().actionCount
	currentBACount = player.GetAdjustedStatComponent().bonusActionCount
	dodge = false
	guard = false
	show()
	OpenCombatMenu()
	pass

func OpenCombatMenu():
	state = CombatState.PlayerMenu
	EndCombatCheck()
	combatMenuUI.HideActionInfo()
	combatMenuUI.HideTopLabel()
	combatMenuUI.SetActionUI(currentActionCount, currentBACount)
	if (currentActionCount <= 0 && currentBACount <= 0):
		_on_end_turn_press()
	else:
		for i in menuButtons.size():
			if menuButtons[i].action && currentActionCount <= 0 || menuButtons[i].bonusAction && currentBACount <= 0:
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

func GetSelectedButton():
	return selectedMenuButtonX + (selectedMenuButtonY * 4)

func SetMainActionDesc(i : int):
	match i:
		0:
			combatMenuUI.SetActionInfo("[font_size=19]Attack - 1A\n[font_size=12]" + player.GetMainHand().GetAction().actionName + ":\n" + player.GetMainHand().GetAction().GetDamageStr(player.GetHitMod(player.GetMainHand().GetAction().statMod), player.GetDamageMod(player.GetMainHand().GetAction().statMod)))
		1:
			combatMenuUI.SetActionInfo("[font_size=19]OffHand - 1BA\n[font_size=12]" + player.GetOffHand().GetAction().actionName + ":\n" + player.GetOffHand().GetAction().GetDamageStr(player.GetHitMod(player.GetOffHand().GetAction().statMod), player.GetDamageMod(player.GetOffHand().GetAction().statMod)))
		2:
			combatMenuUI.SetActionInfo("[font_size=19]Skills")
		3, 7, 11:
			combatMenuUI.SetActionInfo("[font_size=19]End Turn")
		4:
			combatMenuUI.SetActionInfo("[font_size=19]Guard - 1BA")
		5:
			combatMenuUI.SetActionInfo("[font_size=19]Dodge - 1A")
		6:
			combatMenuUI.SetActionInfo("[font_size=19]Items")
		8:
			combatMenuUI.SetActionInfo("[font_size=19]Talk - 1A")
		9:
			combatMenuUI.SetActionInfo("[font_size=19]Re-Equip - 1A")
		10:
			combatMenuUI.SetActionInfo("[font_size=19]Flee - 1A")
		_:
			combatMenuUI.SetActionInfo("")

func TargetEnemy():
	state = CombatState.SelectEnemy
	enemy_selection.BeginSelect()
	DisplaySelectedPart()
	pass

func DisplaySelectedPart():
	combatMenuUI.SetTopLabelText(enemy_selection.GetSelectionText())
	combatMenuUI.SetActionInfo("[font_size=19]Hit Chance: \n" + str(GetHitChance()) + "%")

func GetHitChance() -> int:
	var hitChance : float = enemy_selection.selectedParts[0].GetAC() - (player.GetHitMod(currentAction.statMod) + currentAction.GetActionHitBonus())
	hitChance = hitChance/20
	hitChance *= -1
	hitChance += 1
	hitChance *= 100
	return int(hitChance)

func DoPlayerAttack():
	state = CombatState.PlayerAttack
	combatMenuUI.SetTopLabelText(currentAction.actionName)
	await get_tree().create_timer(0.4).timeout
	for i in enemy_selection.selectedParts:
		PlayerHitAttack(i)	
	combatMenuUI.SetHealthUI(player)
	RemoveActionCount()
	OpenCombatMenu()
	pass

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
			while hasAttack && currentActionCount > 0 || hasAttack && currentBACount > 0:
				var result: Action_Enemy = e.GetEnemyAction(currentActionCount, currentBACount, usedLimbs)
				if (result != null):
					BAAction = result.bonusAction
					var selectedEnemyAction: Action = result.action
					var selectedEnemyPart: EnemyBodyPart = result.GetParent()
					await get_tree().create_timer(0.4).timeout
					result.UsedAction()
					usedLimbs.append(selectedEnemyPart)
					currentAction = selectedEnemyAction
					combatMenuUI.SetTopLabelText(currentAction.actionName)
					selectedEnemyPart.SelectPart()
					await get_tree().create_timer(0.6).timeout
					selectedEnemyPart.DeselectPart()
					await get_tree().create_timer(0.4).timeout
					match currentAction.targetType:
						2:
							if currentAction.IsHealDieUsed():
								e.Heal(currentAction.GetActionHeal(), currentAction.healType)
						0, _: DoEnemyHitAttack(e, result)
					if !result.freeAction:
						RemoveActionCount()
					await get_tree().create_timer(0.2).timeout
					combatMenuUI.HideTopLabel()
					await get_tree().create_timer(0.3).timeout
				else:
					hasAttack = false
		e.UpdateActionPoints()
	TickEnemyConditions()
	pass

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

func DoHitAttack(attacker : Entity, target, adv : bool = false, dis : bool = false):
	var d20 : int = RollD20(adv, dis)
	var crit : bool = false
	#print(d20)
	if d20 >= 20 - attacker.GetCritStat() : crit = true
	var rollValue : int = d20 + attacker.GetHitMod(currentAction.statMod)
	var toHitDC = 0
	#print(rollValue)
	if currentAction.occultAttack : toHitDC = target.GetMC()
	else : toHitDC = target.GetAC()
	if rollValue >= toHitDC:
		if crit == true:
			return 2
		else:
			return 1
	else:
		return 0

func PlayerHitAttack(selected : EnemyBodyPart):
	if selectedUsable != null:
		selectedUsable.OnUse(player)
		selectedUsable = null
		combatMenuUI.UpdateHealthUI(player)
	for i in currentAction.attackCount:
		var h = DoHitAttack(player, selected, player.GetAdvantage(), player.GetDisadvantage())
		if h > 0:
			var damage : int = 0
			var heal : int = 0
			##Main Damage
			if currentAction.IsDmgDieUsed():
				damage = currentAction.GetActionDamage(player.GetStat(currentAction.statMod), h == 2)
				selected.TakeDamage(damage, currentAction.damageType, h==2 && currentAction.dieCount > 0)
				if currentAction.lifeSteal:
					HealPlayer(damage, currentAction.healType)
			#Bonus Damage
			if currentAction.IsBnsDieUsed():
				damage = currentAction.GetActionBnsDamage(h == 2)
				selected.TakeDamage(int(damage), currentAction.bnsDamageType, h==2  && currentAction.bnsDieCount > 0)
			#Bleed Damage
			if currentAction.IsBloodDieUsed():
				damage = currentAction.GetActionBloodDamage(h == 2)
				selected.enemy.AdjustBlood(-damage)
				selected.CreateDamageText("BLD" + str(damage), Color.DARK_RED)
				combatMenuUI.DisplayNote("The enemy bleeds " + str(damage))
				if currentAction.bloodLifeSteal:
					player.AdjustBlood(damage)
			#PlayerHealOnHit
			if currentAction.healOnHit && currentAction.IsHealDieUsed():
				heal = currentAction.GetActionHeal()
				HealPlayer(heal, currentAction.healType)
			#Add StatusEffect
			for statusEffect in currentAction.applyStatusChance:
				if randi() % 100 + 1 <= currentAction.applyStatusChance.get(statusEffect):
					selected.enemy.AddStatusEffect(statusEffect, selected)
		else:
			selected.AttackMiss()
		await get_tree().create_timer(0.4).timeout
	pass

func DoEnemyHitAttack(e : Enemy, eAction : Action_Enemy):
	for i in currentAction.attackCount:
		var h = DoHitAttack(e, player, eAction.GetParent().GetAdvantage(), dodge || eAction.GetParent().GetDisadvantage())
		if h > 0:
			if h == 2 : 
				if eAction.critText != "":
					combatMenuUI.DisplayNote(eAction.critText)
			if currentAction.IsDmgDieUsed():
				DamagePlayer(eAction, e.GetStat(currentAction.statMod), h==2)
			#Bleed Damage
			if currentAction.IsBloodDieUsed():
				var dmg = currentAction.GetActionBloodDamage(h == 2)
				player.AdjustBlood(-dmg)
				combatMenuUI.DisplayNote("You bleed " + str(dmg))
				if currentAction.bloodLifeSteal:
					e.AdjustBlood(dmg)
			#EnemHealOnHit
			if currentAction.healOnHit && currentAction.IsHealDieUsed():
				var heal = currentAction.GetActionHeal()
				e.Heal(heal, currentAction.healType)
		else:
			combatMenuUI.DisplayNote(eAction.missText)
		await get_tree().create_timer(0.4).timeout

func DamagePlayer(eAction : Action_Enemy, eStat : int, crit : bool = false, eBodyTarget : String = ""):
	var dmg : int = 0
	var damagedLimb : PlayerBodyLimb = player.player_body.GetBodyPart(GetDamagedPlayerTarget(eBodyTarget, crit, currentAction.damageType))
	#Add Base Damage
	dmg = currentAction.GetActionDamage(eStat, crit)
	if guard && currentAction.damageType >= 5:
		dmg = int(dmg * GetGuardReduction())
	dmg = player.TakeDamage(dmg, currentAction.damageType, damagedLimb)
	var damageAmountText = str(dmg) + " " + Global.DamageType.keys()[currentAction.damageType]
	#Add Bns Damage
	if currentAction.IsBnsDieUsed():
		dmg = currentAction.GetActionBnsDamage(crit)
		if guard && currentAction.bnsDamageType >= 5:
			dmg = int(dmg * GetGuardReduction())
		dmg = player.TakeDamage(dmg, currentAction.bnsDamageType, damagedLimb)
		damageAmountText += " + " + str(dmg) + " " + Global.DamageType.keys()[currentAction.bnsDamageType]
	#Add StatusEffect
	for statusEffect in currentAction.applyStatusChance:
		if randi() % 100 + 1 <= currentAction.applyStatusChance.get(statusEffect):
			player.AddStatusEffect(statusEffect, damagedLimb)
	#Update Ui
	combatMenuUI.DisplayNote(eAction.hitText + damageAmountText + " damage")
	combatMenuUI.UpdateHealthUI(player)
	combatMenuUI.ScreenShake(dmg)

func GetDamagedPlayerTarget(eTarget : String, crit : bool, damageType : Global.DamageType):
	var damagedTarget : String = eTarget
	if damagedTarget == "" && crit:
		match damageType:
			2: damagedTarget = "Organ"
			5: damagedTarget = "Limb"
			6: damagedTarget = "Head"
			0,1,3,4,_: 
				if guard:
					damagedTarget = "MainHand"
				else:
					damagedTarget = "Limb"
	return eTarget

func SelfAction(): 
	if currentAction.IsHealDieUsed():
		HealPlayer(currentAction.GetActionHeal(), currentAction.healType)
	if selectedUsable != null:
		selectedUsable.OnUse(player)
		selectedUsable = null
		combatMenuUI.UpdateHealthUI(player)
	RemoveActionCount()
	OpenCombatMenu()

func HealPlayer(healAmount : int, healType : String):
	player.Heal(healAmount, healType)
	combatMenuUI.DisplayNote("You heal " + str(healAmount))
	combatMenuUI.UpdateHealthUI(player)
	pass

func EndCombatCheck():
	var aliveEnemy : bool
	for e in enemy:
		if !e.dead:
			aliveEnemy = true
	if player.currentHealth <= 0 || !aliveEnemy:
		EndCombat()
		return true
	else:
		return false

func EndCombat():
	state = CombatState.EndCombat
	await get_tree().create_timer(2.0).timeout
	for i in enemy:
		i.GetEnemyBattle().reparent(i)
		i.GetEnemyBattle().hide()
	player.OpenOverworld()
	enemy.clear()
	currentAction = null
	hide()
	pass

func GetGuardReduction():
	var guardReduc = 0.1 * player.GetAdjustedStatComponent().GetStat(0)
	if guardReduc < 0.05 : guardReduc = 0.05
	if guardReduc > 0.75 : guardReduc = 0.75
	return 1-guardReduc 

func RollD20(advantage : bool, disadvantage : bool):
	var d20 : int = randi_range(1, 20)
	if (advantage && !disadvantage):
		var newd20 : int = randi_range(1, 20)
		if newd20 > d20 : d20 = newd20
	if (disadvantage && !advantage):
		var newd20 : int = randi_range(1, 20)
		if newd20 < d20 : d20 = newd20
	return d20


func _on_attack_press() -> void:
	currentAction = player.GetMainHand().GetAction()
	BAAction = false
	TargetEnemy()
	pass

func _on_offhand_press() -> void:
	currentAction = player.GetOffHand().GetAction()
	BAAction = true
	TargetEnemy()
	pass


func _on_guard_press() -> void:
	guard = true
	currentBACount -= 1
	OpenCombatMenu()
	pass


func _on_dodge_press() -> void:
	dodge = true
	currentActionCount -= 1
	OpenCombatMenu()
	pass  # Replace with function body.


func _on_end_turn_press() -> void:
	TickPlayerConditions()
	pass # Replace with function body.

func TickPlayerConditions():
	if player.player_body.HasStatusEffects():
		await get_tree().create_timer(0.2).timeout
		combatMenuUI.SetTopLabelText("End Turn")
		player.player_body.TickStatusEffects()
		combatMenuUI.UpdateHealthUI(player)
		await get_tree().create_timer(1).timeout
		combatMenuUI.HideTopLabel()
	BeginEnemyCombat()

@export var itemButtonScene : PackedScene
@export var skillButtonScene : PackedScene
@onready var usableContainer: VBoxContainer = $Background/CombatPanel/UsablesContatiner
var usablesIndex : int = 0
var usableObjects : Array
var selectedUsable

func _on_skills_press() -> void:
	if player.GetUsableSkills().size() > 0:
		state = CombatState.PlayerInv
		usableContainer.show()
		PopulateSkillUI(usableContainer, 6, 16)
		usableObjects[usablesIndex].SelectButton()

func _on_items_press() -> void:
	if player.GetUsableItems():
		state = CombatState.PlayerInv
		usableContainer.show()
		PopulateItemsUI(usableContainer, 6, 16)
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
		currentAction = a
		usableContainer.hide()
		if a.targetType == 2 : SelfAction()
		else : TargetEnemy()

func CloseUsablesInv():
	usableContainer.hide()
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
