class_name Enemy_BattleUI extends Control
@export var enemyParts : Array[EnemyBodyPart]
var enemyActions : Array[Action_Enemy]
var currentPhase : int = 0
@export var phaseChangeSFXPath : AudioStream
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	for i in enemyParts:
		i.SetEnemy(get_parent())
		i.Initialise(self)
		for j in i.get_children():
			if j is Action_Enemy:
				enemyActions.append(j)
		if i.allowedPhase == -1 || i.allowedPhase == currentPhase:
			i.EnablePart()
		else: 
			i.DisablePart()

func SetPartsPhase():
	for i in enemyParts:
		if i.allowedPhase == -1 || i.allowedPhase == currentPhase:
			i.EnablePart()
		else: 
			i.DisablePart()
		i.SetPartSprites()

func ChangePhase(newPhase : int):
	if newPhase > currentPhase:
		currentPhase = newPhase
		var audioPlayer = AudioStreamPlayer.new()
		add_child(audioPlayer)
		audioPlayer.stream = phaseChangeSFXPath
		audioPlayer.play()
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.BLACK, 0.6)
		await get_tree().create_timer(0.6).timeout
		tween.stop()
		SetPartsPhase()
		tween = create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, 0.6)
		await audioPlayer.finished
		audioPlayer.queue_free()

func GetEnemyParts() -> Array[EnemyBodyPart]:
	var allowedArray : Array[EnemyBodyPart]
	for i in enemyParts:
		var p = i.GetBodyPart()
		if p != null:
			allowedArray.append(p)
	return allowedArray

func GetEnemyActions() -> Array[Action_Enemy]:
	var allowedArray : Array[Action_Enemy]
	for i in enemyActions:
		var a = i.GetAction(currentPhase)
		if a != null:
			allowedArray.append(a)
	return allowedArray

func SetConstantSFX(clip : AudioStream):
	if audio_stream_player_2d != null:
		print("A")
		audio_stream_player_2d.stream = clip
		audio_stream_player_2d.play()
