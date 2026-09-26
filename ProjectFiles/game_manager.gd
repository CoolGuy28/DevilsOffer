class_name game_manager extends Node
var pausedEntities : bool
var inCombat : bool = false
var playerBaseStats : StatComponent_Player = preload("uid://bqsxbaka2d2kx")
var playerName : String = "Moira"
var debugMode : int = 0

func SetPause(pause : bool):
	pausedEntities = pause

func GetPause():
	return pausedEntities

func SetCombatState(i : bool):
	inCombat = i

func GetCombatState():
	return inCombat

func _ready() -> void:
	await get_tree().process_frame
	if debugMode == -1:
		LoadMenu()
	else:
		LoadGameScene(debugMode)
	pass

func SetDefaultPlayerStats():
	playerBaseStats = load("res://Nodes/Entity/Player/DefaultPlayerStats.tres")

func LoadGameScene(i : int):
	LoadScene("res://Nodes/Maps/GameScene.tscn")
	SceneSwitcher.openScene.LoadMap(i)

func LoadSavedGameScene():
	LoadScene("res://Nodes/Maps/GameScene.tscn")
	SaveManager.load_game(PackedStringArray(["Saves", "Slot 1"]))
	SceneSwitcher.openScene.LoadFromSave()

func LoadMenu():
	LoadScene("res://Nodes/Maps/TitleScreen.tscn")

func LoadScene(p_scene_path: String) : 
	SceneSwitcher.switch_to(p_scene_path)

func UnloadScene():
	SceneSwitcher.UnloadScene()

const SELECT = preload("res://SFX/Actions/UI/select.ogg")
const HOVER = preload("res://SFX/Actions/UI/hover.ogg")
const CANCEL = preload("res://SFX/Actions/UI/cancel.ogg")
func PlayMenuSFX(s : String):
	var audioPlayer = AudioStreamPlayer.new()
	add_child(audioPlayer)
	var stream = null
	match s:
		"Hover": stream = HOVER
		"Cancel": stream = CANCEL
		"Select", _: stream = SELECT
	audioPlayer.volume_db = linear_to_db(0.3)
	audioPlayer.pitch_scale = 1
	audioPlayer.stream = stream
	audioPlayer.play()
	await audioPlayer.finished
	audioPlayer.queue_free()
