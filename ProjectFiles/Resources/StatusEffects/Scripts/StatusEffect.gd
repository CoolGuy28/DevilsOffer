class_name StatusEffect extends SaveKitResource
@export var name : String
@export var sprite : Texture2D
@export var tags : Array[String]

func OnGain(_target): pass

func OnTick(_target): pass

func OnEnd(_target): pass

func GetName():
	return name
