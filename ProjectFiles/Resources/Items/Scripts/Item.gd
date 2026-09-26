class_name Item extends Resource
@export var itemName : String

@export_multiline var description : String
@export var itemTags : Array[Global.ItemTags]

func HasTag(searchTag : Global.ItemTags):
	if !itemTags.is_empty():
		for i in itemTags:
			if i == searchTag:
				return true
	return false

func GetDescription(_short : bool = false):
	return description
