class_name PlayerBodyPart_Resource extends Resource
@export var texturePath : String
@export var leftRightVarients : bool
@export var maxHP : int

func GetMaxHP():
	return maxHP

func GetTexturePath():
	var textPath = "res://Sprites/UI/OverworldMenu/BodypartSprites/" + texturePath
	return textPath
