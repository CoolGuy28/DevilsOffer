class_name game_ui extends Control
@onready var scene_panel: PanelContainer = $ScenePanel
@onready var animatedPanel: TextureRect = $ScenePanel/MarginContainer/Panel

var animationActive : bool
var curFrames : Array[Texture2D]
var frameIndex = 0
var frameRate : float = 0.2

func _ready() -> void:
	HideAnimationPanel()

func SetAnimationPanel(t : Array[Texture2D]):
	curFrames = t.duplicate()
	scene_panel.show()
	if !animationActive : 
		scene_panel.modulate = Color.TRANSPARENT
		var tween = create_tween()
		tween.tween_property(scene_panel, "modulate", Color.WHITE, 0.6)
		animationActive = true
		AnimateFrames()
	else:
		frameIndex = 0
		animatedPanel.texture = curFrames[frameIndex]

func AnimateFrames():
	if !animationActive : return
	animatedPanel.texture = curFrames[frameIndex]
	await get_tree().create_timer(frameRate).timeout
	frameIndex += 1
	if frameIndex >= curFrames.size():
		frameIndex = 0
	AnimateFrames()

func HideAnimationPanel():
	var tween = create_tween()
	tween.tween_property(scene_panel, "modulate", Color.TRANSPARENT, 0.6)
	await tween.finished
	animationActive = false
	scene_panel.hide()
