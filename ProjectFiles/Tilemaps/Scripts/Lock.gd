class_name Lock extends Node
@export var useKeyText : Array[String]
@export var pickedLockText : Array[String]
@export var lockedText : Array[String]
@export var key : Item
@export var expendKey : bool
@export var pickLockable : bool
@export var pickLockDC : int = 10
var player : Player

func UseKey():
	player.OpenDialogue(useKeyText)
	queue_free()


func ApplySkillCheck(d20 : int):
	if d20 >= pickLockDC:
		player.OpenDialogue(pickedLockText)
		queue_free()
	else:
		player.OpenDialogue(lockedText)
