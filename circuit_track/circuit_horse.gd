class_name circuit_horse

extends CharacterBody2D

enum horse_type {player,other}

@export var type: horse_type
@export var speed: int = 10
@export var endurance: int = 10
@export var jump: int = 10

@onready var ap = $AnimatedSprite2D
@onready var race_timer = $"../RaceStartTimer"

var elapsed_time: float = 0.0
var noise = FastNoiseLite.new()
var rng = RandomNumberGenerator.new()
var race_booster = rng.randf_range(-0.03, 0.03)
var perfect_start = false
var perfect_start_speed_bonus: float
var perfect_start_window: float
const speed_factor = 1.0  # Adjust this constant to scale overall movement

func _ready() -> void:
	if type == horse_type.player:
		speed = Global.player_horse.speed
		jump = Global.player_horse.jump
		endurance = Global.player_horse.endurance
		perfect_start_speed_bonus = .05 * speed + 1.5
		perfect_start_window = .1 * endurance

	else:
		speed = Global.RACES[Global.race_difficulty]["npc_speed"]
		endurance = Global.RACES[Global.race_difficulty]["npc_endurance"]

	noise.seed = randi()
	noise.frequency = .020
	ap.play('walk')

func _physics_process(delta: float) -> void:
	if Global.race_started:
		move_horse(delta)
	else:
		if race_timer.time_left <= 0.5:
			# if the player presses the button within the last 0.5 seconds, they get a perfect start
			if Input.is_action_just_pressed("primary_action") and type == horse_type.player:
				perfect_start = true
				print("Perfect Start!")

func move_horse(delta: float) -> void:
	elapsed_time += delta
	var noise_val = noise.get_noise_1d(position.x)
	var multiplier = lerp(0.5 + (endurance * 0.01), 2.0, (noise_val + 1.0) / 2.0)
	var new_speed = (speed * multiplier * delta * speed_factor) + race_booster
	if elapsed_time < perfect_start_window and perfect_start == true:
		new_speed *= perfect_start_speed_bonus
	position.x += new_speed
	ap.speed_scale = new_speed * 3
