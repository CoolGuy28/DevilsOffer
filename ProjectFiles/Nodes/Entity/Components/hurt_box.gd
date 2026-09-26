class_name HurtBox extends Area2D

func _ready() -> void:
	area_entered.connect( AreaEntered )
	pass

signal Hit(p)
func AreaEntered( a : Area2D ):
	if a is HitBox:
		Hit.emit(a.GetPlayer(), true)
