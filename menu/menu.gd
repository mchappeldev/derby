extends Node2D

const STABLE_SCENE = preload("res://stable/stable.tscn")

@onready var start_game_button: Button = %StartGameButton

func _ready() -> void:
	start_game_button.grab_focus()

func _on_start_game_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.button_sound)
	get_tree().change_scene_to_packed(STABLE_SCENE)

func _on_quit_button_pressed() -> void:
	SoundManager.play_sound(SoundManager.button_sound)
	get_tree().quit()







#func _ready() -> void:
	#var menu_buttons = get_tree().get_nodes_in_group("menu_buttons")
	#for menu_button in menu_buttons:
		#menu_button.pressed.connect(_launch_game.bind(menu_button))

#func _launch_game(menu_button) -> void:
	#get_tree().change_scene_to_packed(menu_button.scene);
