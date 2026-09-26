class_name Map extends Node2D
@onready var tilemaps: Node2D = $Tilemaps

func EnableMap():
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
	for c in tilemaps.get_children():
		if c is TileMapLayer:
			c.enabled = true
			for prop in c.get_children():
				if prop is Interactable:
					prop.EnableInteractable()
		if c is CollisionShape2D:
			c.disabled = false
		if c is Node2D:
			for prop in c.get_children():
				if prop is Interactable:
					prop.EnableInteractable()
				if prop is CollisionObject2D:
					prop.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE

func DisableMap():
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	for c in tilemaps.get_children():
		if c is TileMapLayer:
			c.enabled = false
			for prop in c.get_children():
				if prop is Interactable:
					prop.DisableInteractable()
		if c is CollisionShape2D:
			c.disabled = true
		if c is Node2D:
			for prop in c.get_children():
				if prop is Interactable:
					prop.DisableInteractable()
				if prop is CollisionObject2D:
					prop.disable_mode = CollisionObject2D.DISABLE_MODE_REMOVE
