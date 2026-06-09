class_name HorseBreed
extends Resource

## A "kind"/species of horse. Defines the base stats and visuals a freshly
## caught/bought horse of this breed starts with. Call instance() to mint a new
## HorseData from it. Breeds are registered in HorseRegistry.

@export var id: String = "belgian"
@export var display_name: String = "Belgian"

# Visuals used by the race scenes to draw this breed.
@export var sprite_frames: SpriteFrames

# Base stats a new horse of this breed is created with.
@export var base_speed: int = 10
@export var base_endurance: int = 10
@export var base_jump: int = 10
@export var base_strength: int = 10

## Mint a fresh HorseData from this breed's base stats.
func instance() -> HorseData:
	var horse := HorseData.new()
	horse.breed_id = id
	horse.display_name = display_name
	horse.speed = base_speed
	horse.endurance = base_endurance
	horse.jump = base_jump
	horse.strength = base_strength
	horse.experience = 0
	return horse
