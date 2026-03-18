class_name HitBox extends Area2D
signal Hit(e)
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func BeginFight(e : Enemy):
	Hit.emit(e)

func GetCollider():
	return collision_shape_2d
