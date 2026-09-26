class_name AnimateWhenApproached extends Area2D
@onready var parentEnemy: Enemy = $".."
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSpite2D
@export var enteredSFX : AudioStream
@export var exitSFX : AudioStream
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	area_entered.connect( AreaEntered )
	area_exited.connect( AreaExited )
	pass

func AreaEntered( _a : Area2D ):
	if parentEnemy.dead : 
		visible = false
		return
	animatedSprite.animation = "enter"
	animatedSprite.play()
	if enteredSFX == null : return
	audio_stream_player_2d.stream = enteredSFX
	audio_stream_player_2d.play()

func AreaExited( _a : Area2D ):
	if parentEnemy.dead :
		visible = false
		return
	animatedSprite.animation = "exit"
	animatedSprite.play()
	if exitSFX == null : return
	audio_stream_player_2d.stream = exitSFX
	audio_stream_player_2d.play()
