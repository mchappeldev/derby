extends Node2D

@onready var speed_amount_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/SpeedHBox/SpeedAmount
@onready var endurance_amount_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/EnduranceHBox/EnduranceAmount
@onready var jump_label_amount = $CanvasLayer/Control/MarginContainer/VBoxContainer/JumpHBox/JumpAmount
@onready var strength_amount_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/StrengthHBox/StrengthAmount
@onready var money_amount_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer/MoneyVBox/MoneyAmount
@onready var experience_amount_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer/ExperienceVBox/ExperienceAmount
@onready var slow_race_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/RaceHBox/SlowRaceButton
@onready var quick_race_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/RaceHBox/QuickRaceButton
@onready var fast_race_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/RaceHBox/FastRaceButton
@onready var harness_pull_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/RaceHBox/HarnessPullButton
@onready var upgrade_speed_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/SpeedHBox/AddSpeedButton
@onready var upgrade_endurance_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/EnduranceHBox/AddEnduranceButton
@onready var upgrade_jump_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/JumpHBox/AddJumpButton
@onready var upgrade_strength_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/StrengthHBox/AddStrengthButton

const RACE_COSTS = {
	"slow": Global.RaceType.SLOW,
	"quick": Global.RaceType.QUICK,
	"fast": Global.RaceType.FAST
}

func _ready() -> void:
	upgrade_speed_button.pressed.connect(upgrade_stat.bind("speed"))
	upgrade_endurance_button.pressed.connect(upgrade_stat.bind("endurance"))
	upgrade_jump_button.pressed.connect(upgrade_stat.bind("jump"))
	upgrade_strength_button.pressed.connect(upgrade_stat.bind("strength"))
	slow_race_button.pressed.connect(enter_race.bind("slow"))
	quick_race_button.pressed.connect(enter_race.bind("quick"))
	fast_race_button.pressed.connect(enter_race.bind("fast"))
	harness_pull_button.pressed.connect(enter_harness_pull)
	update_ui()

func upgrade_stat(stat: String) -> void:
	if Global.player_horse.experience >= 1:
		Global.player_horse.experience -= 1
		Global.player_horse[stat] += 1
		print("%s increased to: %d" % [stat, Global.player_horse[stat]])
		play_sound()
		update_ui()
	else:
		print("Not enough experience to increase %s." % stat)

func enter_race(race: String) -> void:
	var race_type = RACE_COSTS[race]
	var cost = Global.RACES[race_type]["cost"]
	if Global.money >= cost:
		Global.money -= cost
		Global.race_difficulty = race_type
		play_sound()
		get_tree().change_scene_to_file("uid://cn2xfb3q1u5lk") #circuit_track UID

func enter_harness_pull() -> void:
	var cost = Global.PULLS[Global.pull_difficulty]["cost"]
	if Global.money >= cost:
		Global.money -= cost
		play_sound()
		get_tree().change_scene_to_file("res://harness_pull/pull_track.tscn")

func update_ui() -> void:
	speed_amount_label.text = str(Global.player_horse.speed)
	endurance_amount_label.text = str(Global.player_horse.endurance)
	jump_label_amount.text = str(Global.player_horse.jump)
	strength_amount_label.text = str(Global.player_horse.strength)
	money_amount_label.text = str(Global.money)
	experience_amount_label.text = str(Global.player_horse.experience)
	slow_race_button.disabled = Global.money < Global.RACES[Global.RaceType.SLOW]["cost"]
	quick_race_button.disabled = Global.money < Global.RACES[Global.RaceType.QUICK]["cost"]
	fast_race_button.disabled = Global.money < Global.RACES[Global.RaceType.FAST]["cost"]
	harness_pull_button.disabled = Global.money < Global.PULLS[Global.pull_difficulty]["cost"]

func play_sound() -> void:
	SoundManager.play_sound(SoundManager.button_sound)
