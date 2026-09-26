class_name PhysicsD20 extends RigidBody3D
@onready var startPos: Node3D = $".."
@onready var edge_detectors: Node3D = $EdgeDetectors

# Roll detection
var sleepThreshold : float = 0.1
var sleepTimeRequired : float = 0.5
var sleepTimer : float = 0.0
var rolled : bool = false

signal EndD20Roll(i : int)

# Sounds
const TAP_REVERB = preload("res://SFX/Actions/UI/Dice/Tap_reverb.wav")
const TAP_REVERB_2 = preload("res://SFX/Actions/UI/Dice/Tap_reverb_2.wav")
const TAP_REVERB_3 = preload("res://SFX/Actions/UI/Dice/Tap_reverb_3.wav")

var tap_sounds = [TAP_REVERB, TAP_REVERB_2, TAP_REVERB_3]

# Audio
@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Tap control
var tapCooldown := 0.05
var tapTimer := 0.0
var minImpactThreshold := 1.0

func _ready() -> void:
	# Enable collision signals
	contact_monitor = true
	max_contacts_reported = 10
	body_entered.connect(_on_body_entered)
	# Setup audio
	add_child(audio_player)

func _physics_process(delta: float) -> void:
	# Tap cooldown timer
	tapTimer -= delta
	# Roll finished detection
	if !rolled:
		var moving := linear_velocity.length() > sleepThreshold \
			or angular_velocity.length() > sleepThreshold
		
		if moving:
			sleepTimer = 0.0
		else:
			sleepTimer += delta
			
		if sleepTimer >= sleepTimeRequired:
			rolled = true
			EndD20Roll.emit(GetHighestPoint())

func RollD20():
	transform = startPos.transform
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	var randDir : Vector3 = Vector3(randf_range(-1,1), 0, randf_range(-1,1))
	apply_force(randDir.normalized() * 2000)
	apply_torque(Vector3(
		randf_range(-10,10),
		randf_range(-10,10),
		randf_range(-10,10)
	) * 500)

	sleepTimer = 0.0
	rolled = false

func _on_body_entered(_body):
	# Only play sounds while rolling
	if rolled or tapTimer > 0:
		return
	var impact := linear_velocity.length() + angular_velocity.length()
	# Ignore tiny contacts
	if impact < minImpactThreshold:
		return
	tapTimer = tapCooldown
	MakeTapSound(impact)

func MakeTapSound(impact: float):
	var sound = tap_sounds.pick_random()
	audio_player.stream = sound
	# Volume based on impact
	audio_player.volume_db = clamp(remap(impact, 1, 20, -20, 0), -30, 0)
	# Slight pitch variation
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.play()

func GetHighestPoint() -> int:
	var highestPoint : Marker3D = null
	var highestY : float = -INF
	for i in edge_detectors.get_children():
		if i is Marker3D:
			var marker := i as Marker3D
			if marker.global_transform.origin.y > highestY:
				highestY = marker.global_transform.origin.y
				highestPoint = marker
	var val : int = int(highestPoint.name)
	return val
