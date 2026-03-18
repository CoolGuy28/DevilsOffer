class_name CombatNoteText extends Panel

var preLifetime := 2
var lifetime := 2
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func BeginFade() -> void:
	await get_tree().create_timer(preLifetime).timeout
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, lifetime)
	await tween.finished

	queue_free()

func SetNoteText(value: String):
	rich_text_label.text = value
	modulate = Color(1, 1, 1)
	show()
	BeginFade()
