class_name PlayerBodypart_MenuUI extends TextureRect
@export var bodypartNodeIndex : int
var bodyPart : PlayerBodyPart
@export_category("Nav")
@export var UpPart : PlayerBodypart_MenuUI
@export var LeftPart : PlayerBodypart_MenuUI
@export var RightPart : PlayerBodypart_MenuUI
@export var DownPart : PlayerBodypart_MenuUI
@onready var statusEffectBox: HBoxContainer = get_node_or_null("StatusEffects")
const STATUS_EFFECT_ICON = preload("uid://cq2hpef781674")

func SetTexture(playerBodypart : PlayerBodyPart):
	texture = playerBodypart.GetTexture()
	bodyPart = playerBodypart

func SetStatusEffectDisp(a):
	if statusEffectBox == null : return
	for i in statusEffectBox.get_children():
		i.queue_free()
	for statusEffect in a:
		var statusIcon = STATUS_EFFECT_ICON.instantiate()
		statusIcon.get_child(0).texture = statusEffect.sprite
		statusEffectBox.add_child(statusIcon)

func SelectPart():
	self_modulate = Color(1.385, 1.147, 0.704, 1.0)

func DeselectPart():
	self_modulate = Color(1,1,1)
