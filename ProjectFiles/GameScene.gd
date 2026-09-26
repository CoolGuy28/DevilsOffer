class_name GameScene extends Node2D
@export var floors : Array[Map]
@export var loadedFloorIndex : int
@export var player : Player
const PLAYER = preload("uid://6q62pgau4d4g")

func _ready() -> void:
	for i in floors:
		i.DisableMap()

func LoadFromSave() -> void:
	floors[loadedFloorIndex].EnableMap()

func LoadMap(i : int, playerPosX : int = 0, playerPosY : int = 0):
	await SceneSwitcher.FadeIn()
	floors[loadedFloorIndex].DisableMap()
	loadedFloorIndex = i
	floors[loadedFloorIndex].EnableMap()
	SetPlayerPos(Vector2(playerPosX, playerPosY))
	await SceneSwitcher.FadeOut()

func SetPlayerPos(playerPos : Vector2 = Vector2.ZERO):
	if player != null:
		player.position = playerPos
	else: 
		CreatePlayerObj()

func CreatePlayerObj(_position : Vector2 = Vector2.ZERO) :
	if player != null:
		player.queue_free()
	var newPlayer = PLAYER.instantiate()
	add_child(newPlayer)
	player = newPlayer
	SetPlayerPos(position)
	player.baseStats = GameManager.playerBaseStats
	if !GameManager.playerName.is_empty():
		player.SetName(GameManager.playerName)
	player.SetAdjustedStatComponent()
