class_name HorseData
extends Resource

## Travelling state for a single horse. This is the object that gets carried
## around the game (owned by the player, stored in a stable, handed to a race
## scene) instead of the old flat stat block on Global. Create new ones via
## HorseBreed.instance() / HorseRegistry.instance().

@export var display_name: String = "Horse"
@export var breed_id: String = "belgian"

# Core stats. Upgraded by spending experience in the stable.
@export var speed: int = 10
@export var endurance: int = 10
@export var jump: int = 10
@export var strength: int = 10

# Spent as currency to upgrade the stats above.
@export var experience: int = 0
