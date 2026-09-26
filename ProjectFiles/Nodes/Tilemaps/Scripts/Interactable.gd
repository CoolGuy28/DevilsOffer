class_name Interactable extends StaticBody2D
@export var disabled : bool
@export_storage var spriteFrame : int = 0
@export var dialogueText : String = "Empty"
@export var interacted : bool
@export var interacted2 : bool
@export var interacted3 : bool
@export var interacted4 : bool
@export var playInteractSFX : bool
@onready var sprite_2d = get_node_or_null("Sprite2D")
@onready var collision_shape_2d: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var audio_node: AudioNode = get_node_or_null("AudioNode")
@export var leftText : bool
var INTERACTION_TEXT : DialogueResource = preload("res://Dialogue/InteractionText.dialogue")
signal InteractionEnded()
const BALLOON_LEFT = preload("uid://cl04h3t81e5yq")

func _ready() -> void:
	SaveManager.after_load.connect(_on_after_load)
	SaveManager.before_save.connect(_on_before_save)

func _on_after_load() -> void:
	ChangeSpriteFrame(spriteFrame)

func _on_before_save() -> void:
	if sprite_2d is SpriteTextures:
		spriteFrame = sprite_2d.GetTextureIndex()
	elif sprite_2d is Sprite2D:
		spriteFrame = sprite_2d.frame

func Interact(_player : Player):
	if playInteractSFX && !interacted: PlaySFX("Interact")
	GameManager.SetPause(true)
	if leftText:
		DialogueManager.show_dialogue_balloon_scene(BALLOON_LEFT, INTERACTION_TEXT, dialogueText, [self, { "player" = _player }, { "relation" = _player.GetRelations() }])
	else:
		DialogueManager.show_dialogue_balloon(INTERACTION_TEXT, dialogueText, [self, { "player" = _player }, { "relation" = _player.GetRelations() }])
	await DialogueManager.dialogue_ended
	GameManager.SetPause(false)
	InteractionEnded.emit()

func ChangeSpriteFrame(f : int):
	if sprite_2d is SpriteTextures:
		sprite_2d.SetTexture(f)
	elif sprite_2d is Sprite2D:
		if f < sprite_2d.hframes * sprite_2d.vframes:
			sprite_2d.frame = f

func PlaySFX(s : String):
	if audio_node != null:
		audio_node.PlaySFX(s)

func DisableCollider():
	if collision_shape_2d != null:
		collision_shape_2d.disabled = true

func EnableCollider():
	if collision_shape_2d != null:
		collision_shape_2d.disabled = false

func DisableInteractable():
	visible = false
	for i in get_children():
		if i is CollisionShape2D:
			i.disabled = true

func EnableInteractable():
	visible = true
	for i in get_children():
		if i is CollisionShape2D:
			i.disabled = false

func DeactivateChild(i : int):
	get_child(i).visible = false
	get_child(i).set_process(false)
