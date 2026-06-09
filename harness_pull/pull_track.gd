extends Node2D

@onready var winner_text = $Ui/Control/MarginContainer/BoxContainer/VBoxContainer/Winner
@onready var timer = $RaceStartTimer
@onready var progress_bar = $Ui/ProgressBar

func _ready() -> void:
	$Area2D.race_finished.connect(_on_race_finished)

func _race_start() -> void:
	Global.race_started = true

func _on_race_finished(winner: Node) -> void:
	calculate_experience(winner)
	$Ui/Control.visible = true

func calculate_experience(winner: Node) -> void:
	var exp_gained: int
	var money_gained: int = 0
	if winner.type == circuit_horse.horse_type.player:
		exp_gained = Global.RACES[Global.race_difficulty]["exp_win"]
		money_gained = Global.RACES[Global.race_difficulty]["reward_win"]
		Global.money += money_gained
		Global.experience += exp_gained
	else:
		exp_gained = Global.RACES[Global.race_difficulty]["exp_lose"]
		Global.experience += exp_gained
	winner_text.text = "Winner is: %s, Money gained: %d, Experience Gained: %d" % [winner.name, money_gained, exp_gained]
	
func _physics_process(_delta: float) -> void:
	if timer.time_left > 0:
		progress_bar.value = timer.time_left  
 
