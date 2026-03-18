class_name Interactable extends StaticBody2D
@export var interacted : bool
@export_multiline var interactText : Array[String] = ["You look at the object"]
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var changeSpriteOnInteract : int

func Interact(_player):
	interacted = true
	if changeSpriteOnInteract != 0:
		sprite_2d.frame = changeSpriteOnInteract
	return interactText
