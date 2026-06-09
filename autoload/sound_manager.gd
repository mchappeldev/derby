extends Node

@export var button_sound : AudioStream

@onready var audio_player: AudioStreamPlayer2D = %AudioStreamPlayer2D

func play_sound(sound : AudioStream) -> void:
	audio_player.stream = sound
	audio_player.play()
