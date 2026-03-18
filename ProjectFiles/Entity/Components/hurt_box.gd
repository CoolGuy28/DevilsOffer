class_name HurtBox extends Area2D

func _ready() -> void:
	area_entered.connect( AreaEntered )
	pass
	
func AreaEntered( a : Area2D ):
	if a is HitBox:
		a.BeginFight(get_parent())
	pass
