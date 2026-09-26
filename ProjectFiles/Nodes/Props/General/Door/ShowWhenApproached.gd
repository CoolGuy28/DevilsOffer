class_name ShowWhenApproached extends Area2D
@onready var interaction_icon: Sprite2D = $InteractionIcon
@onready var animation_player: AnimationPlayer = $InteractionIcon/AnimationPlayer

func _ready() -> void:
	interaction_icon.hide()
	animation_player.pause()
	area_entered.connect( AreaEntered )
	area_exited.connect( AreaExited )
	pass

var t : Tween
func AreaEntered( _a : Area2D ):
	interaction_icon.modulate = Color.TRANSPARENT
	interaction_icon.show()
	t = create_tween()
	t.tween_property(interaction_icon, "modulate", Color.WHITE, 0.85)
	animation_player.play("default")

func AreaExited( _a : Area2D ):
	interaction_icon.modulate = Color.WHITE
	t = create_tween()
	t.tween_property(interaction_icon, "modulate", Color.TRANSPARENT, 0.85)
	await t.finished
	interaction_icon.hide()
	animation_player.pause()
