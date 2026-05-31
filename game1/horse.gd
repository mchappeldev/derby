class_name horse

extends CharacterBody2D

enum horse_type {player,other}

@export var type: horse_type
@export var speed: int = 10
@export var jump: int = 10
@export var strength: int = 10

@onready var ap = $AnimatedSprite2D

var noise = FastNoiseLite.new()
var rng = RandomNumberGenerator.new()
var race_booster = rng.randf_range(-0.05, 0.05)
const speed_factor = 1.0  # Adjust this constant to scale overall movement

func _ready() -> void:
	if type == horse_type.player:
		speed = Global.speed
		jump = Global.jump
		strength = Global.endurance
	else:
		speed = Global.RACES[Global.race_difficulty]["npc_speed"]

	noise.seed = randi()
	noise.frequency = 0.2
	ap.play('walk')

func _physics_process(delta: float) -> void:
	var noise_val = noise.get_noise_1d(position.x)
	var multiplier = lerp(0.5, 1.5, (noise_val + 1.0) / 2.0)
	var new_speed = (speed * multiplier * delta * speed_factor) + race_booster
	position.x += new_speed
	
