class_name HitBox extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

signal Hit(e)
func BeginFight(e : Enemy):
	Hit.emit(e)

func GetPlayer():
	return get_parent()

func GetCollider():
	return collision_shape_2d
