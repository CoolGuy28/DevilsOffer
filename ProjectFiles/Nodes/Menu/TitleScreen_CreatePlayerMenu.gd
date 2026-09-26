class_name TitleScreen_CreatePlayerMenu extends Control
@export var createStatDisplays : Array[SelectableText]
var statDisplaysIndex : int = 0
@export var basePlayerAbilityScores : Array[int] = [-1, -1, -1, -1]
signal Close()
@export var pointsAmount : int
@onready var points_display: RichTextLabel = $PointsDisplay
@export var minStatVal : int = -1
@export var maxStatVal : int = 4

func OpenCreatePlayerMenu():
	show()
	set_process(true)
	var a = 0
	for i in createStatDisplays:
		i.DeselectButton()
		i.SetText(str(basePlayerAbilityScores[a]))
		a += 1
	createStatDisplays[statDisplaysIndex].SelectButton()
	SetPointsAmount(0)

const menuDelay : float = 0.15
var keyDelay : bool = false 
func _process(_delta: float) -> void:
	if keyDelay : return
	if Input.is_action_pressed("up"):
		if basePlayerAbilityScores[statDisplaysIndex] >= maxStatVal  || GetPointCost(basePlayerAbilityScores[statDisplaysIndex]) > pointsAmount: return
		SetPointsAmount(GetPointCost(basePlayerAbilityScores[statDisplaysIndex]) * -1)
		basePlayerAbilityScores[statDisplaysIndex] += 1
		createStatDisplays[statDisplaysIndex].SetText(str(basePlayerAbilityScores[statDisplaysIndex]))
		KeyPressDelay()
	if Input.is_action_pressed("down"):
		if basePlayerAbilityScores[statDisplaysIndex] <= minStatVal : return
		basePlayerAbilityScores[statDisplaysIndex] -= 1
		createStatDisplays[statDisplaysIndex].SetText(str(basePlayerAbilityScores[statDisplaysIndex]))
		SetPointsAmount(GetPointCost(basePlayerAbilityScores[statDisplaysIndex]))
		KeyPressDelay()
	if Input.is_action_pressed("left"):
		createStatDisplays[statDisplaysIndex].DeselectButton()
		statDisplaysIndex -= 1
		if statDisplaysIndex < 0 : statDisplaysIndex = createStatDisplays.size() -1
		createStatDisplays[statDisplaysIndex].SelectButton()
		KeyPressDelay()
	if Input.is_action_pressed("right"):
		createStatDisplays[statDisplaysIndex].DeselectButton()
		statDisplaysIndex += 1
		if statDisplaysIndex >= createStatDisplays.size() : statDisplaysIndex = 0
		createStatDisplays[statDisplaysIndex].SelectButton()
		KeyPressDelay()
	if Input.is_action_just_pressed("select"):
		_on_start_game_pressed()
	if Input.is_action_just_pressed("return"):
		Close.emit()

func KeyPressDelay():
	keyDelay = true
	await get_tree().create_timer(menuDelay).timeout
	keyDelay = false
	pass

func _on_start_game_pressed() -> void:
	GameManager.SetDefaultPlayerStats()
	if basePlayerAbilityScores != null:
		GameManager.LoadScene("res://Nodes/Maps/Cutscenes/OpeningCutscene.tscn")
		GameManager.playerBaseStats.stats = basePlayerAbilityScores
	pass

func GetPointCost(statVal : int):
	if statVal < 1:
		return 1
	elif statVal == 1 || 2:
		return 2
	else:
		return 4

func SetPointsAmount(usedVal : int):
	pointsAmount += usedVal
	points_display.text = "Points: " + str(pointsAmount)
