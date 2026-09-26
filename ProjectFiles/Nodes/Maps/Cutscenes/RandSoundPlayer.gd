class_name RandSoundPlayer extends AudioStreamPlayer2D
@export var randSounds : Array[AudioStream]
@export var randTime : Vector2
@export var SetActiveAtStart : bool

func _ready() -> void:
	if SetActiveAtStart: SetActive()

func SetActive() -> void:
	PlaySound()

func PlaySound():
	await get_tree().create_timer(randf_range(randTime.x, randTime.y)).timeout
	stream = randSounds.pick_random()
	play()
	PlaySound()

func Destroy():
	queue_free()
