class_name EntityAnimController extends AnimatedSprite2D
@export var dirMovement : bool
@export var omniMovement : bool
@export var crawlMovement : bool
@export var sprintMovement : bool
@export var disallowMovementAnim : bool

func DisallowMovementAnim(b : bool):
	disallowMovementAnim = b

func SetAnimation(anim : String):
	animation = anim

func SetMovementAnim(dir: Vector2, velocity : Vector2):
	if disallowMovementAnim : return
	var targetAnim = GetAnimDir(dir)
	if velocity == Vector2.ZERO || dirMovement == false: targetAnim += "_Idle"
	#print(targetAnim)
	animation = targetAnim

func SetSprintAnim(dir: Vector2, velocity : Vector2):
	if disallowMovementAnim : return
	var targetAnim = GetAnimDir(dir)
	if velocity == Vector2.ZERO: targetAnim += "_Idle"
	elif sprintMovement: targetAnim += "_Sprint"
	animation = targetAnim

func SetCrawlAnim(dir: Vector2, velocity : Vector2):
	if disallowMovementAnim : return
	var targetAnim = GetAnimDir(dir)
	if crawlMovement: targetAnim += "_Crawl"
	if velocity == Vector2.ZERO: targetAnim += "_Idle"
	animation = targetAnim

func GetAnimDir(velocity : Vector2):
	if velocity.y > 0: return "Down"
	elif velocity.y < 0: return "Up"
	elif velocity.x > 0: return "Right"
	elif velocity.x < 0: return "Left"
	else : return "Down"
