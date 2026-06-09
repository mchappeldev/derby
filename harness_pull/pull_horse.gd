class_name pull_horse
extends Node2D

## Visual + battle state for one competitor in a Harness Pull. Unlike the circuit
## horse this does no physics/noise movement — the turn-based pull_track drives it,
## reading/writing the battle-state fields below and sliding the sprite around.

@onready var ap: AnimatedSprite2D = $AnimatedSprite2D

var data: HorseData
var is_player: bool = true

# Per-battle state (managed by pull_track).
var distance_remaining: float = 100.0   # lower = closer to winning
var endurance_left: int = 10            # Pull/Brace spend this; Rest recovers it
var exhaust_skips_left: int = 0         # forced skip turns after hitting 0 endurance

## Assign the horse + side and reset battle state. Call before add_child so _ready
## can pick up the right breed visuals.
func setup(horse: HorseData, player: bool, start_distance: float) -> void:
	data = horse
	is_player = player
	distance_remaining = start_distance
	endurance_left = horse.endurance
	exhaust_skips_left = 0

func _ready() -> void:
	if data != null:
		var breed := HorseRegistry.get_breed(data.breed_id)
		if breed != null and breed.sprite_frames != null:
			ap.sprite_frames = breed.sprite_frames
	# Player faces right toward the contest; enemy faces left.
	ap.flip_h = not is_player
	ap.play("walk")

## True once this horse has dragged its load all the way home.
func has_won() -> bool:
	return distance_remaining <= 0.0
