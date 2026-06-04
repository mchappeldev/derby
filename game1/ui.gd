extends CanvasLayer

func _on_button_pressed() -> void:
	get_tree().paused = false
	Global.race_started = false
	get_tree().change_scene_to_file("res://stable/stable.tscn")
