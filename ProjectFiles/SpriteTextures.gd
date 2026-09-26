class_name SpriteTextures extends Sprite2D

var textureIndex : int
@export var textures : Array[Texture2D]

func SetTexture(i : int):
	if i < textures.size():
		texture = textures[i]
		textureIndex = i

func GetTextureIndex():
	return textureIndex
