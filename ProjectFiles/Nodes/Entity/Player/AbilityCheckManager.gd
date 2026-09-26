class_name AbilityCheckManager extends Panel
@onready var player: Player = $"../../.."
var skillCheckDC : int
var skillMods : Dictionary
var skillModsObj : Array[AbilityCheckMod]
var advantage : int
var succeeded : bool
var rolling : bool
signal FinishedRolling()
signal EndSkillCheck()
@onready var DiceRoller: AbilityCheck_DiceRoller = $SubViewportContainer/SubViewport/D20PhysicsRoll
@onready var dc: RichTextLabel = $RollScore/DC
@onready var score: RichTextLabel = $RollScore/Score
@onready var scoreAnimator: AnimationPlayer = $RollScore/Score/AnimationPlayer
@onready var rollScoreObj: Sprite2D = $RollScore
@onready var rollModsContainer: HBoxContainer = $RollScore/RollMods
@onready var pentacleRunes: Control = $PentacleRunes
const ABILITY_CHECK_MOD = preload("uid://k37c8pjnbdef")
const NumberSFX = preload("res://SFX/Actions/UI/Dice/Tap_reverb.wav")
const SuccessSFX = preload("res://SFX/Actions/UI/Dice/Tap_reverb.wav")
const FailSFX = preload("res://SFX/Actions/UI/Dice/Tap_reverb.wav")

const difficultyTextSize : int = 15
const dcTextSize : int = 25
const rollTextSize : int = 20
const finalTextSize : int = 45
const scoreFadeSpeed : float = 0.3

func _ready() -> void:
	CloseSkillCheck()

func OpenSkillCheck(skillDC: int, skillModsDic: Dictionary, adv: int) -> void:
	show()
	skillCheckDC = skillDC
	advantage = adv
	skillMods = skillModsDic
	succeeded = false

	# Update UI
	dc.text = "[font_size=%d]Difficulty:\n[font_size=%d]%d" % [
		difficultyTextSize, dcTextSize, skillCheckDC
	]
	
	score.modulate = Color.WHITE
	score.text = "[font_size=%d]Roll" % rollTextSize
	CreateSkillMods()

func AddInspiration():
	if advantage < 0: 
		advantage = 0
		CreateSkillMods()
	elif advantage == 0: 
		advantage = 1
		CreateSkillMods()

func CreateSkillMods():
	skillModsObj.clear()
	# Clear old modifiers
	for child in rollModsContainer.get_children():
		child.queue_free()
	for child : Sprite2D in pentacleRunes.get_children():
		child.modulate = Color.WHITE
	# Create Adv Mod
	if advantage != 0:
		if advantage > 0: CreateSkillModObj("+ADV", "")
		else: CreateSkillModObj("-DIS", "")
	# Create modifier entries
	var usesAbilityScore : bool = false
	for key in skillMods.keys():
		CreateSkillModObj(key, skillMods[key])
		if !usesAbilityScore : usesAbilityScore = HighlightSymbol(key)
		else : HighlightSymbol(key)
	if !usesAbilityScore : HighlightSymbol("SOUL")

func CreateSkillModObj(title, val):
	var newSkillMod : AbilityCheckMod = ABILITY_CHECK_MOD.instantiate()
	rollModsContainer.add_child(newSkillMod)
	skillModsObj.append(newSkillMod)
	newSkillMod.SetMod(title, val)

const symbolGlowCol : Color = Color(1.6,1.6,1.6) 
func HighlightSymbol(mod : String):
	match mod:
		"SOUL" : pentacleRunes.get_child(0).modulate = symbolGlowCol
		"STR" : pentacleRunes.get_child(3).modulate = symbolGlowCol
		"DEX" : pentacleRunes.get_child(4).modulate = symbolGlowCol
		"INT" : pentacleRunes.get_child(1).modulate = symbolGlowCol
		"WIS" : pentacleRunes.get_child(2).modulate = symbolGlowCol
		_: return false
	return true

func CloseSkillCheck():
	DiceRoller.DisableDice()
	hide()
	EndSkillCheck.emit()
	pass

func RollDice():
	for i in skillModsObj:
		if i.GetValue() is Item:
			player.player_inventory.RemoveItem(i.GetValue())
			i.SetText(player)
			i.Wriggle()
	var fadeTween = create_tween()
	fadeTween.tween_property(rollScoreObj, "modulate", Color(1,1,1,0.5), scoreFadeSpeed)
	DiceRoller.RollDice(advantage)
	rolling = true
	score.text = ""

func EndDiceThrow(i: int) -> void:
	var fadeTween = create_tween()
	fadeTween.tween_property(rollScoreObj, "modulate", Color(1,1,1,1), scoreFadeSpeed)
	await fadeTween.finished
	await get_tree().create_timer(0.2).timeout
	rolling = false
	var d20 = i
	score.text = "[font_size=%d]%d" % [finalTextSize, d20]
	d20 = await AddModToDiceRoll(d20)
	if d20 >= skillCheckDC:
		succeeded = true
		score.modulate = Color.LIME_GREEN
		PlaySound(SuccessSFX)
	else:
		score.modulate = Color.DARK_RED
		PlaySound(FailSFX)
	FinishedRolling.emit()
	
func AddModToDiceRoll(d20 : int):
	for mod in skillModsObj:
		var val = mod.GetValue()
		PlaySound(NumberSFX)
		if val is int && val != 0:
			await get_tree().create_timer(0.4).timeout
			mod.Wriggle()
			scoreAnimator.play("AddMod")
			await get_tree().create_timer(0.12).timeout
			d20 += mod.GetValue()
			score.text = "[font_size=%d]%d" % [finalTextSize, d20]
			PlaySound(NumberSFX)
	await get_tree().create_timer(1.2).timeout
	return d20

func PlaySound(sound: AudioStream):
	var p := AudioStreamPlayer.new()
	add_child(p)
	p.stream = sound
	p.play()
	p.finished.connect(p.queue_free)

func GetAdvantage():
	return advantage
