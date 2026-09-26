class_name Player extends Entity
enum PlayerState{Menu, Overworld, Combat}
@export_storage var dead : bool
var state : PlayerState = PlayerState.Overworld
@onready var camera_2d: Camera2D = $Camera2D
@onready var gameUI: game_ui = $Camera2D/UI/GameUI
@onready var combatMenu: combat_menu = $Camera2D/UI/CombatMenu
@onready var overworld_menu: OverworldMenu = $Camera2D/UI/OverworldMenu
@onready var interact_range: Area2D = $InteractRange
@onready var player_inventory: PlayerInventory = $PlayerInventory
@onready var player_body: PlayerBody = $PlayerBody
@onready var relationManager: relation_manager = $relation_manager
@onready var player_light: PointLight2D = $PlayerLight
@onready var abilityCheckManager: AbilityCheckManager = $Camera2D/UI/SavingThrowManager
@onready var transAnim: AnimationPlayer = $Camera2D/UI/SceneTransition/SceneTransitionAnim
@export_storage var currentHealth : int
var keyDelay : bool
@export_storage var inspiration : int

@export var curSprint : float = 1.0

func _ready() -> void:
	SaveManager.after_load.connect(_on_after_load)
	SaveManager.before_save.connect(_on_before_save)
	SetAdjustedStatComponent()
	SetDirection(defaultDir)
	if firstLoad :
		currentBloodLevel = GetMaxBlood()
		currentHealth = adjustedStats.maxHealth - 20
		inspiration = 1
		for i in player_body.GetBodyPart("All"):
			i.InitialisePartNode()
		firstLoad = false

func _on_after_load() -> void:
	print(firstLoad)
	pass

func _on_before_save() -> void:
	pass

func _unhandled_input(_event: InputEvent) -> void:
	if dead: return
	if Input.is_key_label_pressed(KEY_0):
		SaveManager.save_game(PackedStringArray(["Saves", "Slot 1"]), true)
	if Input.is_key_label_pressed(KEY_9):
		GameManager.LoadScene("res://Nodes/Maps/TitleScreen.tscn")
	if Input.is_key_label_pressed(KEY_8):
		baseStats.stats[2] -= 10
	if state == PlayerState.Overworld:
		var newDirection : Vector2 = Vector2.ZERO
		var sprint : bool = false
		newDirection.x = Input.get_action_strength("right") - Input.get_action_strength("left")
		newDirection.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		newDirection.normalized()
		if (Input.get_action_strength("shift")):
			sprint = true
		Movement(newDirection, sprint)
		if (direction.y > 0):
			interact_range.rotation_degrees = 0
		elif  (direction.x > 0):
			interact_range.rotation_degrees = -90
		elif (direction.x < 0):
			interact_range.rotation_degrees = 90
		elif (direction.y < 0):
			interact_range.rotation_degrees = 180
		if Input.is_action_just_pressed("return") : OpenMenu()
		if Input.is_action_just_pressed("select") : CheckForInteractable()
		pass
	elif state == PlayerState.Menu:
		if !keyDelay:
			if Input.is_action_pressed("return") : 
				overworld_menu.GetInput("return")
				KeyPressDelay(menuDelay)
			if Input.is_action_pressed("up") : 
				overworld_menu.GetInput("up")
				KeyPressDelay(menuDelay)
			if Input.is_action_pressed("down") : 
				overworld_menu.GetInput("down")
				KeyPressDelay(menuDelay)
			if Input.is_action_pressed("left") : 
				overworld_menu.GetInput("left")
				KeyPressDelay(menuDelay)
			if Input.is_action_pressed("right") : 
				overworld_menu.GetInput("right")
				KeyPressDelay(menuDelay)
			if Input.is_action_pressed("select") : 
				overworld_menu.GetInput("select")
				KeyPressDelay(menuDelay)
		pass
	elif state == PlayerState.Combat:
		if !keyDelay:
			if Input.is_action_pressed("select"): 
				combatMenu.GetInput("select")
				KeyPressDelay(menuDelay)
			elif Input.is_action_pressed("return"):
				combatMenu.GetInput("return")
				KeyPressDelay(menuDelay)
			elif Input.is_action_pressed("up"):
				combatMenu.GetInput("up")
				KeyPressDelay(menuDelay)
			elif Input.is_action_pressed("down"):
				combatMenu.GetInput("down")
				KeyPressDelay(menuDelay)
			elif Input.is_action_pressed("left"):
				combatMenu.GetInput("left")
				KeyPressDelay(menuDelay)
			elif Input.is_action_pressed("right"):
				combatMenu.GetInput("right")
				KeyPressDelay(menuDelay)
			if Input.is_action_just_pressed("shift"):
				combatMenu.GetInput("shift")
			if Input.is_action_just_released("shift"):
				combatMenu.GetInput("shiftUndo")
		pass

func _physics_process(_delta):
	super(_delta)
	if !GameManager.GetPause() && velocity != Vector2.ZERO && !audioNode.playing:
		PlaySFX("StoneFootstep", 1.7 * currentMoveSpeed)
	CameraMovement(_delta)

func CameraMovement(_delta):
	if Input.get_action_strength("c"):
		camera_2d.position = camera_2d.position.lerp(direction * 210,_delta * 2)
	#elif Input.get_action_strength("shift"):
	#	camera_2d.position = camera_2d.position.lerp(direction * 20,_delta * 1)
	else:
		if camera_2d.position != Vector2.ZERO:
			camera_2d.position = camera_2d.position.lerp(Vector2.ZERO,_delta * 3)

func SetAdjustedStatComponent():
	adjustedStats.CopyStatComponent(baseStats)
	adjustedStats.AddStatComponent(player_inventory.SetInventoryStats())
	adjustedStats.AddStatComponent(player_body.SetBodyStats())
	adjustedStats.UpdateValues()
	SetCurrentValues()

func SetCurrentValues():
	super()
	SetPlayerLight()
	if currentHealth > GetMaxHealth() : currentHealth = GetMaxHealth()
	if currentBloodLevel > GetMaxBlood() : currentBloodLevel = GetMaxBlood()

var basePlayerViewDis : float = 1
var basePlayerLightScale = Vector2(4.5,4.5)
var basePlayerLightBrightness = 200
func SetPlayerLight():
	if adjustedStats is StatComponent_Player:
		camera_2d.zoom = Vector2.ONE * (basePlayerViewDis - adjustedStats.viewDis)
		player_light.color.a8 = basePlayerLightBrightness + adjustedStats.torchBrightness
		player_light.scale = basePlayerLightScale * adjustedStats.torchStrength

func SaveGame():
	SaveManager.save_game(PackedStringArray(["Saves", "Slot 1"]), true)

const menuDelay : float = 0.2
func KeyPressDelay(delayAmount : float):
	keyDelay = true
	await get_tree().create_timer(delayAmount).timeout
	keyDelay = false
	pass

var lookedAtInteractions : Array
var interactionsIndex : int
func CheckForInteractable():
	lookedAtInteractions = interact_range.get_overlapping_bodies()
	if lookedAtInteractions.size() > 1:
		while lookedAtInteractions.size() < 4:
			lookedAtInteractions.append(null)
		DialogueManager.show_dialogue_balloon(Global.GetGlobalDialogue(), "Interact", [self])
	elif lookedAtInteractions.size() == 1:
		interactionsIndex = 0
		Interact()
	pass

func Interact():
	#GameManager.SetPause(true)
	var interaction = lookedAtInteractions[interactionsIndex]
	interaction.Interact(self)
	#if interaction is Interactable:
	await interaction.InteractionEnded
	#elif interaction is Enemy:
	#	await interaction.InteractionEnde
	EndDialogue()

func OpenLockCheck(skillDC : int):
	if player_inventory.GetItem("Lockpick") != null:
		var skillMods : Dictionary = {"DEX" : adjustedStats.stats[1], "State" : adjustedStats.stateBonus}
		if player_inventory.GetItem("Thieves Tools") != null: skillMods["Thieves Tools"] = 2
		abilityCheckManager.OpenSkillCheck(skillDC, skillMods, 0)
		await get_tree().create_timer(0.4).timeout
		while true:
			await get_tree().process_frame
			if Input.is_action_just_pressed("return") || Input.is_action_just_pressed("select") && abilityCheckManager.succeeded || player_inventory.GetItem("Lockpick") == null:
				abilityCheckManager.CloseSkillCheck()
				return
			if Input.is_action_just_pressed("shift") && GetInspiration() > 0 && abilityCheckManager.GetAdvantage() != 1:
				AdjustInspiration(-1)
				abilityCheckManager.AddInspiration()
			if Input.is_action_just_pressed("select"):
				player_inventory.RemoveItem(player_inventory.GetItem("Lockpick"))
				abilityCheckManager.RollDice()
				await abilityCheckManager.FinishedRolling
				continue
		await abilityCheckManager.EndSkillCheck
		pass

func OpenSkillCheck(skillDC : int, skillMod : int):
	var skillMods : Dictionary
	match skillMod:
		0: skillMods["STR"] = adjustedStats.stats[skillMod]
		1: skillMods["DEX"] = adjustedStats.stats[skillMod]
		2: skillMods["INT"] = adjustedStats.stats[skillMod]
		3: skillMods["WIS"] = adjustedStats.stats[skillMod]
	skillMods["State"] = adjustedStats.stateBonus
	abilityCheckManager.OpenSkillCheck(skillDC, skillMods, 0)
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("select"):
			abilityCheckManager.RollDice()
			await abilityCheckManager.FinishedRolling
			while true:
				await get_tree().process_frame
				if Input.is_action_just_pressed("select"):
					abilityCheckManager.CloseSkillCheck()
					return
			return
	await abilityCheckManager.EndSkillCheck
	pass

func OpenSaveThrow(skillDC : int, skillMod : int, adv : int = 0):
	print(get_tree().paused)
	var skillMods : Dictionary
	match skillMod:
		0: skillMods["STR"] = adjustedStats.stats[skillMod]
		1: skillMods["DEX"] = adjustedStats.stats[skillMod]
		2: skillMods["INT"] = adjustedStats.stats[skillMod]
		3: skillMods["WIS"] = adjustedStats.stats[skillMod]
	skillMods["State"] = adjustedStats.stateBonus
	abilityCheckManager.OpenSkillCheck(skillDC, skillMods, adv)
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("select"):
			abilityCheckManager.RollDice()
			await abilityCheckManager.FinishedRolling
			while true:
				await get_tree().process_frame
				if Input.is_action_just_pressed("select"):
					abilityCheckManager.CloseSkillCheck()
					return
			return
	await abilityCheckManager.EndSkillCheck
	pass

func GetSkillCheckSuccess() -> bool:
	return abilityCheckManager.succeeded

func OpenMenu():
	KeyPressDelay(menuDelay)
	state = PlayerState.Menu
	GameManager.SetPause(true)
	velocity = Vector2.ZERO
	overworld_menu.OpenMenu()
	player_inventory.SetInventoryStats()

func BeginBattle(e : Enemy) -> void:
	if state == PlayerState.Overworld && e.dead != true:
		OpenCombat(e)
	pass # Replace with function body.

func OpenCombat(e : Enemy):
	transAnim.play("CombatTransition")
	PlaySFX("BeginCombat")
	await get_tree().create_timer(1).timeout
	state = PlayerState.Combat
	GameManager.SetPause(true)
	GameManager.SetCombatState(true)
	gameUI.visible = false
	velocity = Vector2.ZERO
	combatMenu.BeginCombat(self, e)
	pass

func OpenOverworld() -> void:
	state = PlayerState.Overworld
	GameManager.SetPause(false)
	GameManager.SetCombatState(false)
	await get_tree().process_frame
	gameUI.show()
	gameUI.HideAnimationPanel()
	pass

func SetAnimationPanel(t : String):
	var animationTextures : TexturesArray = load("res://Sprites/CutsceneSprites/" + t + ".tres")
	gameUI.SetAnimationPanel(animationTextures.GetTextures())

func HideAnimationPanel():
	gameUI.HideAnimationPanel()

func EndDialogue():
	HideAnimationPanel()

func TakeDamage(_damage : Dictionary[Global.DamageType, int], damageTargets : Array[PlayerBodyPart] = [], hitmessage : String = "You take ", guard : bool = false):
	var dString = hitmessage
	var multipleDamageTypes : bool = false
	for dType in _damage:
		var dmg : int = _damage[dType]
		if guard && dType < 2: 
			dmg *= GetGuardReduction()
			dmg -= GetAdjustedStatComponent().guardDamageReduction
		var dmgRes : float = GetDamageResist(dType)
		if dmgRes != 1:
			dmg = int(dmg * dmgRes)
		if dmg < 0: dmg = 0
		currentHealth -= dmg
		if !damageTargets.is_empty():
			var limbDamage : int = dmg
			if dType > 2:
				limbDamage = int(limbDamage * 0.5)
			TakeLimbDamage({dType : limbDamage}, damageTargets, !multipleDamageTypes)
		if currentHealth <= 0:
			currentHealth = 0
			if !dead : KillPlayer()
		if multipleDamageTypes : dString += " +"
		dString += str(dmg) + " " + Global.DamageType.keys()[dType]
		multipleDamageTypes = true
	PlayerEmitNote(dString)

func TakeLimbDamage(_damage : Dictionary[Global.DamageType, int], damageTargets : Array[PlayerBodyPart], makeNote : bool = true):
	for i in damageTargets:
		if i != null && !i.destroyed:
			i.PartDestroyed.connect(BodyPartDestroyed)
			for dType in _damage:
				i.TakeDamage(_damage[dType], dType)
			i.PartDestroyed.disconnect(BodyPartDestroyed)
			if makeNote && !i.destroyed && damageTargets.size() < 3:
				PlayerEmitNote("Your %s hurts" %i.name)

func Heal(heal : int, healTargets : Array[PlayerBodyPart] = [], regrowParts : bool = false):
	var h = super(heal, healTargets)
	if !healTargets.is_empty():
		for i in healTargets:
			i.HealPart(heal, regrowParts)
	currentHealth += h
	PlayerEmitNote("Your body heals " + str(h))
	if currentHealth > GetMaxHealth() : currentHealth = adjustedStats.maxHealth

func AdjustBlood(bloodAdj : int, spawnsBlood : bool = true):
	super(bloodAdj, spawnsBlood)
	#if bloodAdj < 0:
	#	PlayerEmitNote("You bleed " + str(bloodAdj))

func AddStatusEffect(statusEffect : StatusEffect, _target : Array[PlayerBodyPart] = []):
	for i in GetStatusImmunities():
		if statusEffect == Global.GetStatusEffect(i):
			return
	player_body.AddStatusEffect(statusEffect, _target)

func RemoveStatusEffect(statusEffectTag : String, _target): 
	player_body.RemoveStatusEffect(statusEffectTag, _target)

func AttackMiss():
	pass

func KillPlayer():
	PlaySFX("Death")
	var collision : CollisionShape2D = find_child("CollisionShape2D")
	collision.disabled = true
	disable_mode = CollisionObject2D.DISABLE_MODE_REMOVE
	animatedSprite.DisallowMovementAnim(true)
	PlayAnimation("Death")
	dead = true
	if state == PlayerState.Combat:
		await combatMenu.CombatFinished
	if state == PlayerState.Menu:
		overworld_menu.CloseMenu()
	await get_tree().create_timer(7.5).timeout
	GameManager.LoadMenu()

func GiveHeartAttack():
	print("HeartAttack")

func AddItem(item : Item, amount : int):
	player_inventory.AddItem(item, amount)

func AddItemPath(itemPath : String, amount : int = 1):
	var i = load("res://Resources/Items/Items/" + itemPath + ".tres")
	if i is Item:
		player_inventory.AddItem(i, amount)

signal EmitNote(s : String)
func PlayerEmitNote(message : String):
	EmitNote.emit(message)

func BodyPartDestroyed(s : String, v : bool):
	PlayerEmitNote(s)
	if v == true:
		TakeDamage({Global.DamageType.Bleed : 999})
	else:
		SetAdjustedStatComponent()
		CheckHeldItems()

func CheckHeldItems():
	if player_body.GetArmCount() == 1:
		if player_inventory.GetOffHand() != null:
			var message : String = "You can no longer hold your %s" % player_inventory.GetOffHand().itemName
			EmitNote.emit(message)
			player_inventory.UnequipWeapon(1)
		elif player_inventory.GetMainHand() != null && player_inventory.GetMainHand().weaponType == 2:
			var message : String = "You cannot hold %s one handed" % player_inventory.GetMainHand().itemName
			EmitNote.emit(message)
			player_inventory.UnequipWeapon(0)
	if player_body.GetArmCount() <= 0:
		if player_inventory.GetOffHand() != null:
			var message : String = "You can no longer hold your %s" % player_inventory.GetOffHand().itemName
			EmitNote.emit(message)
			player_inventory.UnequipWeapon(1)
		if player_inventory.GetMainHand() != null:
			var message : String = "You can no longer hold your %s" % player_inventory.GetMainHand().itemName
			EmitNote.emit(message)
			player_inventory.UnequipWeapon(0)

func GetMainHand(): 
	if player_inventory.GetWeapon(0) != null:
		return player_inventory.GetWeapon(0).GetAction()
	else:
		return player_body.GetMainArm().GetUnarmedAttack()

func GetOffHand():
	if player_inventory.GetWeapon(1) != null:
		return player_inventory.GetWeapon(1).GetAction()
	else:
		return player_body.GetOffArm().GetUnarmedAttack()

func GetCurrentHealth(): return currentHealth
func GetMaxHealth(): return adjustedStats.maxHealth

func GetUsableSkills() -> Array[Skill_Action]:
	return adjustedStats.GetUsableSkills()

func GetPassiveSkills() -> Array[Skill_Passive]:
	return adjustedStats.GetPassiveSkills()

func GetUsableItems() -> Dictionary[Item, int]:
	return player_inventory.GetUsableItems()

func GetPassiveItems() -> Array[Item_Equippable]:
	return player_inventory.GetEquippedAccessories()

func HasItem(item : String, amount : int = 1):
	return GetInventory().HasItem(item, amount)

func RemoveItem(item : String):
	player_inventory.RemoveItemName(item)

func GetBody() -> PlayerBody:
	return player_body

func GetInventory() -> PlayerInventory:
	return player_inventory

func GetRelations() -> relation_manager:
	return relationManager

func SetName(s : String):
	GetRelations().SetPlayerName(s)

func GetMaxBlood():
	return maxBloodLevel + adjustedStats.maxBlood

func AdjustInspiration(i : int):
	inspiration += i
	if inspiration <= 0 : inspiration = 0

func GetInspiration():
	return inspiration

func GetNutrition(): return player_inventory.GetNutritionAmount()

func RemoveNutrition(amount : int): player_inventory.RemoveNutrition(amount)

func GetStatusImmunities() -> Array[Global.StatusEffectTypes]:
	var a : Array[Global.StatusEffectTypes] = statusImmunities
	a.append_array(adjustedStats.statusImmunities)
	return a

func GetGuardStat() : 
	if GetInventory().HasEquippedAccessory("Thieves Pendant"):
		return GetStat(1)
	return GetStat(0)

func GetGuardReduction():
	var guardReduc = 0.1 * GetGuardStat()
	if guardReduc < 0.05 : guardReduc = 0.05
	if guardReduc > 0.75 : guardReduc = 0.75
	return 1-guardReduc 
