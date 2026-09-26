class_name AudioNode extends AudioStreamPlayer2D
@export var soundEffects : Dictionary[String, AudioStream]

func PlaySFX(s : String, p : float = 1.0):
	if !soundEffects.has(s): return
	var aud = soundEffects[s]
	if aud == null : return
	stream = aud
	volume_db = linear_to_db(0.6)
	pitch_scale = p
	play()
