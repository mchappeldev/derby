extends Node

## Autoload registry of horse breeds. Right now breeds are defined here in code;
## later this can load HorseBreed .tres files from a folder. This is the hook the
## game uses to "instance a kind of horse" when one is caught or bought.

const HORSE_SHEET := preload("res://assets/horse-belgian.png")

var _breeds: Dictionary = {}

func _ready() -> void:
	_register_builtin_breeds()

func _register_builtin_breeds() -> void:
	var belgian := HorseBreed.new()
	belgian.id = "belgian"
	belgian.display_name = "Belgian"
	belgian.sprite_frames = _make_walk_frames(HORSE_SHEET)
	belgian.base_speed = 10
	belgian.base_endurance = 10
	belgian.base_jump = 10
	belgian.base_strength = 10
	register(belgian)

## Add (or replace) a breed in the registry.
func register(breed: HorseBreed) -> void:
	_breeds[breed.id] = breed

## Look up a registered breed definition.
func get_breed(breed_id: String) -> HorseBreed:
	return _breeds.get(breed_id)

## Mint a fresh HorseData of the given breed. Returns null if unknown.
func instance(breed_id: String) -> HorseData:
	var breed: HorseBreed = _breeds.get(breed_id)
	if breed == null:
		push_error("HorseRegistry: unknown breed_id '%s'" % breed_id)
		return null
	return breed.instance()

## Build a looping "walk" SpriteFrames from a horse sheet (4 frames, row y=32).
func _make_walk_frames(sheet: Texture2D) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.set_animation_loop("default", true)
	frames.rename_animation("default", "walk")
	frames.set_animation_speed("walk", 5.0)
	for i in range(4):
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(i * 32, 32, 32, 32)
		frames.add_frame("walk", atlas)
	return frames
