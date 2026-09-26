class_name AbilityCheckMod extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var title
var value
const modMainTextSize : int = 18
const modValTextSize : int = 24

func SetMod(text : String, val):
	title = text
	value = val
	SetText()

func SetText(_p : Player = null):
	if value is int:
		var s := "+" if value >= 0 else ""
		rich_text_label.text = "[font_size=%d]%s\n[font_size=%d]%s%d" % [
				modMainTextSize, title,
				modValTextSize, s, value
			]
	else:
		rich_text_label.text = "[font_size=%d]%s" % [modValTextSize, title]

func Wriggle():
	animation_player.play("Wriggle")

func GetValue():
	return value
