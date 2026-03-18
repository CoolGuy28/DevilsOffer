class_name DamageText extends Label

@export var lifetime := 8        # how long it lasts
@export var float_distance := 60 # how far it moves

func BeginMovement() -> void:
	randomize()
	var dir := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var target_pos := position + dir * float_distance
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, lifetime)
	tween.parallel().tween_property(self, "modulate:a", 0.0, lifetime)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func set_damage_text(value: String, colour : Color = Color.WHITE):
	text = value
	modulate = colour
	show()
	BeginMovement()
