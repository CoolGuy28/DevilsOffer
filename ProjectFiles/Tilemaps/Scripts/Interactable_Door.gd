class_name Interactable_Door extends Interactable
@export var lock : Lock
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if interacted:
		OpenDoor()

func Interact(_player):
	if lock != null:
		lock.player = _player
		_player.OpenSkillCheck(lock.pickLockDC, 0, lock)
	if interacted == false and lock == null:
		OpenDoor()
	elif interacted == true:
		CloseDoor()

func OpenDoor():
	interacted = true
	set_collision_layer_value(5, false)
	sprite_2d.frame = 1

func CloseDoor():
	interacted = false
	set_collision_layer_value(5, true)
	sprite_2d.frame = 0
