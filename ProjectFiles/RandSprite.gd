@tool
extends Sprite2D

@export var randomize_sprite: bool = false:
	set(value):
		if value and hframes > 0 and vframes > 0:
			# Parentheses ensure we modulo by the total number of grid cells
			frame = randi() % (hframes * vframes)
