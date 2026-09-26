class_name EnemyBodyPartTexture extends TextureRect
const stringPath : String = "res://Sprites/Entity/"
@export var folderName : String
@export var textureName : String = ""
@export var changeOnPhase : bool
@export var changeOnStage : bool
@export var changeOnDestroyed : bool = true

func SetTexture(texturePath : String, bodyPart : EnemyBodyPart):
	var loadPath : String = stringPath + texturePath + "/Combat/" + folderName + "/" + textureName
	if bodyPart.damagedPart && changeOnDestroyed: loadPath += "_Destroyed"
	elif changeOnPhase:
		if bodyPart.battleUI.currentPhase > 0 : loadPath += "_" + str(bodyPart.battleUI.currentPhase+1)
	elif changeOnStage:
		if bodyPart.currentStage > 0 : loadPath += "_" + str(bodyPart.currentStage+1)
	loadPath += ".png"
	#assert(FileAccess.file_exists(loadPath), "Texture path does not exist: %s" % [loadPath])
	if FileAccess.file_exists(loadPath):
		texture = load(loadPath)
	else:
		printerr("Texture path does not exist: %s" % [loadPath])

var damage_tween : Tween = null
func TweenToWhite(f : float):
	KillTween()
	damage_tween = create_tween()
	damage_tween.tween_property(self, "self_modulate", Color.WHITE, f)

func KillTween():
	if damage_tween and damage_tween.is_running():
		damage_tween.kill()
