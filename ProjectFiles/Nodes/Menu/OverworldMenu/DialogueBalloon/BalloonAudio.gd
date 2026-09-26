class_name BalloonAudio extends AudioStreamPlayer
const SELECT = preload("uid://dqf4n7sxlnpnt")
const TAP_REVERB = preload("uid://njrgbkdpkwpj")

func Speak(_l,_li,_s):
	stream = TAP_REVERB
	pitch_scale = _s * randf_range(0.75, 0.9)
	play()

func Skip():
	pass

func Select(_r):
	stream = game_manager.SELECT
	play()
	pass

func Hover(_r):
	stream = game_manager.HOVER
	play()
	pass
