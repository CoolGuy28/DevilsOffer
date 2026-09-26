class_name Lock extends Node
@export var key : Item
@export var expendKey : bool
@export var pickLockable : bool
@export var pickLockDC : int = 10

func GetKey():
	if key == null:
		return ""
	else:
		return key.itemName

func IsPickable():
	return pickLockable

func ExpendKey():
	return expendKey
