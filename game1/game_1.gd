extends Node2D

@onready var winner_text = $Ui/Control/MarginContainer/BoxContainer/VBoxContainer/Winner

func _ready() -> void:
	$Area2D.race_finished.connect(_on_race_finished)


func _on_race_finished(winner: Node) -> void:
	#get_tree().paused = true
	calculate_experience(winner)
	$Ui.visible = true

func calculate_experience(winner: Node) -> void:
	var exp_gained: int
	var money_gained: int = 0
	if winner.type == horse.horse_type.player:
		exp_gained = Global.RACES[Global.race_difficulty]["exp_win"]
		money_gained = Global.RACES[Global.race_difficulty]["reward_win"]
		Global.money += money_gained
		Global.experience += exp_gained
	else:
		exp_gained = Global.RACES[Global.race_difficulty]["exp_lose"]
		Global.experience += exp_gained
	winner_text.text = "Winner is: %s, Money gained: %d, Experience Gained: %d" % [winner.name, money_gained, exp_gained]
	
