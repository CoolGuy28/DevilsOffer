class_name Item extends Resource
@export var itemName : String
@export_multiline var description : String
@export var itemTags : Array[String]

func HasTag(searchTag : String):
	for i in itemTags:
		if i == searchTag:
			return true
	return false
