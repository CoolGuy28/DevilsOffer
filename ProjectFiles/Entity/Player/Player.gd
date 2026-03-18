class_name Player extends Entity
enum PlayerState{Menu, Overworld, Dialogue, Combat, Dead}
var state : PlayerState = PlayerState.Overworld
var skillCheckNode
@onready var camera_2d: Camera2D = $Camera2D
@onready var combatMenu: combat_menu = $Camera2D/UI/CombatMenu
@onready var overworld_menu: OverworldMenu = $Camera2D/UI/OverworldMenu
@onready var overworld_ui: OverworldUI = $Camera2D/UI/OverworldUI
@onready var interact_range: Area2D = $InteractRange
@onready var player_inventory: PlayerInventory = $PlayerInventory
@onready var player_body: PlayerBody = $PlayerBody
@onready var transAnim: AnimationPlayer = $Camera2D/UI/SceneTransition/SceneTransitionAnim
var currentHealth : int
var keyDelay : bool

func _ready() -> void:
	super()
	currentHealth = adjustedStats.maxHealth

func _process(_delta: float) -> void:
	if skillCheckNode != null:
		if Input.is_action_just_pressed("select") :
			var d20 = overworld_ui.ProcessSkillCheck()
			if (skillCheckNode is Lock):
				var a : Lock = skillCheckNode as Lock
				a.ApplySkillCheck(d20)
			skillCheckNode = null
	elif state == PlayerState.Overworld:
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
	elif state == PlayerState.Dialogue:
		if !keyDelay:
			if Input.is_action_just_pressed("select") : 
				overworld_ui.ProcessDialogue()
				KeyPressDelay()
		pass
	elif state == PlayerState.Menu:
		if !keyDelay:
			if Input.is_action_pressed("return") : 
				overworld_menu.GetInput("return")
				KeyPressDelay()
			if Input.is_action_pressed("up") : 
				overworld_menu.GetInput("up")
				KeyPressDelay()
			if Input.is_action_pressed("down") : 
				overworld_menu.GetInput("down")
				KeyPressDelay()
			if Input.is_action_pressed("left") : 
				overworld_menu.GetInput("left")
				KeyPressDelay()
			if Input.is_action_pressed("right") : 
				overworld_menu.GetInput("right")
				KeyPressDelay()
			if Input.is_action_pressed("select") : 
				overworld_menu.GetInput("select")
				KeyPressDelay()
		pass
	elif state == PlayerState.Combat:
		if !keyDelay:
			if Input.is_action_pressed("select"): 
				combatMenu.GetInput("select")
				KeyPressDelay()
			elif Input.is_action_pressed("return"):
				combatMenu.GetInput("return")
				KeyPressDelay()
			elif Input.is_action_pressed("up"):
				combatMenu.GetInput("up")
				KeyPressDelay()
			elif Input.is_action_pressed("down"):
				combatMenu.GetInput("down")
				KeyPressDelay()
			elif Input.is_action_pressed("left"):
				combatMenu.GetInput("left")
				KeyPressDelay()
			elif Input.is_action_pressed("right"):
				combatMenu.GetInput("right")
				KeyPressDelay()
		pass

func _physics_process(_delta):
	super(_delta)
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
	adjustedStats.AddStatComponent(player_inventory.inventoryStats)
	player_body.SetBodyStats()
	adjustedStats.AddStatComponent(player_body.bodyStats)
	adjustedStats.UpdateValues()

func KeyPressDelay():
	keyDelay = true
	await get_tree().create_timer(0.2).timeout
	keyDelay = false
	pass

func CheckForInteractable():
	if interact_range.get_overlapping_bodies().size() > 0:
		var interaction : Interactable = interact_range.get_overlapping_bodies()[0]
		var interactionText = interaction.Interact(self)
		if interactionText != null:
			OpenDialogue(interactionText)
	pass

func OpenDialogue(text : Array[String]):
	KeyPressDelay()
	state = PlayerState.Dialogue
	get_tree().paused = true
	velocity = Vector2.ZERO
	overworld_ui.OpenTextBox(text)

func OpenSkillCheck(skillDC : int, skillMod : int, skillNode):
	overworld_ui.OpenSkillCheck(skillDC, skillMod)
	self.skillCheckNode = skillNode
	pass

func OpenMenu():
	KeyPressDelay()
	state = PlayerState.Menu
	get_tree().paused = true
	velocity = Vector2.ZERO
	overworld_menu.OpenMenu()
	player_inventory.SetInventoryStats()

func _on_hit_box_hit(e : Enemy) -> void:
	if e.dead != true:
		OpenCombat(e)
	pass # Replace with function body.

func OpenCombat(e : Enemy):
	transAnim.play("CombatTransition")
	await get_tree().create_timer(1).timeout
	state = PlayerState.Combat
	get_tree().paused = true
	velocity = Vector2.ZERO
	combatMenu.BeginCombat(self, e)
	pass

func OpenOverworld() -> void:
	state = PlayerState.Overworld
	get_tree().paused = false
	pass

func TakeDamage(damage : int, dmgType : Global.DamageType, damageTarget : PlayerBodyLimb = null):
	var dmg : int = damage
	var dmgRes : float = GetDamageResist(dmgType)
	if damageTarget != null:
		dmg = damageTarget.TakeDamage(dmg, dmgType)
	elif dmgRes != 1:
		dmg = int(dmg * dmgRes)
	if dmg < 0: dmg = 0
	currentHealth -= dmg
	if currentHealth <= 0:
		currentHealth = 0
		KillPlayer()
	return dmg

func Heal(heal : int, type : String):
	var h = super(heal, type)
	print("Heal")
	match type:
		"Body":
			currentHealth += h
		"All", _:
			currentHealth += h
	if currentHealth > adjustedStats.maxHealth : currentHealth = adjustedStats.maxHealth

func AddStatusEffect(statusEffect : StatusEffect, _target): 
	player_body.GainStatusEffect(statusEffect, _target)

func KillPlayer():
	var hitbox : CollisionShape2D = find_child("HitBox").get_child(0)
	hitbox.disabled = true
	print("kill")

func GetMainHand() -> Item_Weapon: 
	if player_inventory.GetWeapon(0) != null:
		return player_inventory.GetWeapon(0)
	else:
		var newWeap := Item_Weapon.new()
		newWeap.CreateUnarmed()
		return newWeap

func GetOffHand() -> Item_Weapon:
	if player_inventory.GetWeapon(1) != null:
		return player_inventory.GetWeapon(1)
	else:
		var newWeap := Item_Weapon.new()
		newWeap.CreateUnarmed()
		return newWeap

func GetCurrentHealth(): return currentHealth
func GetMaxHealth(): return adjustedStats.maxHealth

func GetUsableSkills() -> Array[Skill_Action]:
	return adjustedStats.GetUsableSkills()

func GetUsableItems() -> Dictionary[Item, int]:
	return player_inventory.GetUsableItems()
