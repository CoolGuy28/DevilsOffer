class_name Bloodstain extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.frame = randi() % 15
