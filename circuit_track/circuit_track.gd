extends RaceBase

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
	var player_won: bool = winner.type == circuit_horse.horse_type.player
	var result := award_results(player_won, Global.RACES[Global.race_difficulty])
	winner_text.text = "Winner is: %s, Money gained: %d, Experience Gained: %d" % [winner.name, result["money"], result["exp"]]
	
func _physics_process(_delta: float) -> void:
	if timer.time_left > 0:
		progress_bar.value = timer.time_left  
 
