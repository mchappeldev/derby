extends Node2D

@onready var speed_amount_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/SpeedHBox/SpeedAmount
@onready var endurance_amount_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/EnduranceHBox/EnduranceAmount
@onready var jump_label_amount = $CanvasLayer/Control/MarginContainer/VBoxContainer/JumpHBox/JumpAmount
@onready var money_amount_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer/MoneyVBox/MoneyAmount
@onready var experience_amount_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer/ExperienceVBox/ExperienceAmount
@onready var slow_race_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/RaceHBox/SlowRaceButton
@onready var quick_race_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/RaceHBox/QuickRaceButton
@onready var fast_race_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/RaceHBox/FastRaceButton
@onready var upgrade_speed_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/SpeedHBox/AddSpeedButton
@onready var upgrade_endurance_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/EnduranceHBox/AddEnduranceButton
@onready var upgrade_jump_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/JumpHBox/AddJumpButton

const RACE_COSTS = {
	"slow": Global.RaceType.SLOW,
	"quick": Global.RaceType.QUICK,
	"fast": Global.RaceType.FAST
}

func _ready() -> void:
	upgrade_speed_button.pressed.connect(upgrade_stat.bind("speed"))
	upgrade_endurance_button.pressed.connect(upgrade_stat.bind("endurance"))
	upgrade_jump_button.pressed.connect(upgrade_stat.bind("jump"))
	slow_race_button.pressed.connect(enter_race.bind("slow"))
	quick_race_button.pressed.connect(enter_race.bind("quick"))
	fast_race_button.pressed.connect(enter_race.bind("fast"))
	update_ui()

func upgrade_stat(stat: String) -> void:
	if Global.experience >= 1:
		Global.experience -= 1
		Global[stat] += 1
		print("%s increased to: %d" % [stat, Global[stat]])
		update_ui()
	else:
		print("Not enough experience to increase %s." % stat)

func enter_race(race: String) -> void:
	var race_type = RACE_COSTS[race]
	var cost = Global.RACES[race_type]["cost"]
	if Global.money >= cost:
		Global.money -= cost
		Global.race_difficulty = race_type
		get_tree().change_scene_to_file("uid://cn2xfb3q1u5lk") #circuit_track UID

func update_ui() -> void:
	speed_amount_label.text = str(Global.speed)
	endurance_amount_label.text = str(Global.endurance)
	jump_label_amount.text = str(Global.jump)
	money_amount_label.text = str(Global.money)
	experience_amount_label.text = str(Global.experience)
	slow_race_button.disabled = Global.money < Global.RACES[Global.RaceType.SLOW]["cost"]
	quick_race_button.disabled = Global.money < Global.RACES[Global.RaceType.QUICK]["cost"]
	fast_race_button.disabled = Global.money < Global.RACES[Global.RaceType.FAST]["cost"]
