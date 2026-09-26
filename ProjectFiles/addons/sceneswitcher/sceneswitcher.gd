extends Node

signal finished

const PROPERTY_NAME_TRANSITION_DELAY = "plugins/scene_swicther/transition_delay"
const PROPERTY_NAME_FADE_DURATION = "plugins/scene_swicther/fade_duration"

var canvas_layer: CanvasLayer
var fade_rect: ColorRect

@onready var fade_duration: float = ProjectSettings.get_setting(PROPERTY_NAME_FADE_DURATION, 0.5)
@onready var transition_delay: float = ProjectSettings.get_setting(PROPERTY_NAME_TRANSITION_DELAY, 2.0)

var openScene : Node

func _enter_tree() -> void:
	if not ProjectSettings.has_setting(PROPERTY_NAME_FADE_DURATION):
		ProjectSettings.set_setting(PROPERTY_NAME_FADE_DURATION, 0.5)
		ProjectSettings.add_property_info({
			"name": PROPERTY_NAME_FADE_DURATION,
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		ProjectSettings.save()
	
	if not ProjectSettings.has_setting(PROPERTY_NAME_TRANSITION_DELAY):
		ProjectSettings.set_setting(PROPERTY_NAME_TRANSITION_DELAY, 2.0)
		ProjectSettings.add_property_info({
			"name": PROPERTY_NAME_TRANSITION_DELAY,
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		ProjectSettings.save()


func _exit_tree() -> void:
	ProjectSettings.clear(PROPERTY_NAME_FADE_DURATION)
	ProjectSettings.clear(PROPERTY_NAME_TRANSITION_DELAY)


func _ready() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Ensure it's on top
	
	add_child(canvas_layer)

	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1)

	# Set anchors to cover the entire screen
	fade_rect.anchor_left = 0
	fade_rect.anchor_top = 0
	fade_rect.anchor_right = 1
	fade_rect.anchor_bottom = 1

	# Ignore mouse events
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	canvas_layer.add_child(fade_rect)

	await get_tree().create_timer(transition_delay).timeout

	# Initial fade out
	await get_tree().create_tween().tween_property(fade_rect, "modulate:a", 0, fade_duration).finished
	finished.emit()


## Smoothly switches the current scene to another one, with a fade in-out effect.
func switch_to(p_scene_path: String):
	assert(FileAccess.file_exists(p_scene_path), "Scene path does not exist: %s" % p_scene_path)

	# Fade In
	FadeIn()

	var newScene = load(p_scene_path).instantiate()
	if openScene != null:
		UnloadScene()
	openScene = newScene
	get_node("/root/SceneRoot").add_child(newScene)

	FadeOut()
	finished.emit()

func UnloadScene():
	openScene.queue_free()

func FadeIn():
	await get_tree().create_tween().tween_property(fade_rect, "modulate:a", 1.0, fade_duration).finished

func FadeOut():
	await get_tree().create_timer(transition_delay).timeout
	# Fade Out
	get_tree().create_tween().tween_property(fade_rect, "modulate:a", 0, fade_duration)
