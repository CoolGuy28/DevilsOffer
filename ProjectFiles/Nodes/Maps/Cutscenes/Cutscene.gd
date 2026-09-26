class_name Cutscene extends Map
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var dialogueFile : DialogueResource = preload("res://Dialogue/Cutscenes.dialogue")
@export var dialogueAfterSceneLoad : String = ""
@export var dialogueAfterSceneLoadTimer : float = 3.0

func _ready() -> void:
	if dialogueAfterSceneLoad != "":
		await SceneSwitcher.finished
		await get_tree().create_timer(dialogueAfterSceneLoadTimer).timeout
		PlayDialogue(dialogueAfterSceneLoad)

func PlayDialogue(s : String):
	if dialogueFile != null:
		DialogueManager.show_dialogue_balloon(dialogueFile, s, [self])

func PlayAnim(s : String):
	if animation_player.has_animation(s):
		animation_player.play(s)

func ChangeScene(s : String):
	GameManager.LoadScene("res://Nodes/Maps/" + s + ".tscn")

func ChangeSceneAddPlayer():
	GameManager.LoadGameScene(0)
