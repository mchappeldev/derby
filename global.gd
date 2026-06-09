extends Node

enum RaceType { SLOW, QUICK, FAST }

const RACES = {
	RaceType.SLOW:  { "cost": 0,   "npc_speed": 10,  "npc_endurance": 10, "reward_win": 25,   "exp_win": 2,  "exp_lose": 1 },
	RaceType.QUICK: { "cost": 50,  "npc_speed": 20, "npc_endurance": 20, "reward_win": 150,  "exp_win": 5,  "exp_lose": 2 },
	RaceType.FAST:  { "cost": 500, "npc_speed": 30, "npc_endurance": 30, "reward_win": 1000, "exp_win": 10, "exp_lose": 3 },
}

# Harness Pull events. Keyed like RACES so more tiers can be added later.
enum PullType { LOCAL }

const PULLS = {
	PullType.LOCAL: { "cost": 0, "npc_breed": "belgian", "npc_strength": 10, "npc_endurance": 10, "reward_win": 75, "exp_win": 4, "exp_lose": 2 },
}

# The player's active horse. All stats now live on this object instead of as
# flat globals. Minted from a breed via the HorseRegistry autoload.
var player_horse: HorseData

# Player Stats
var money: int = 0

# Selected event difficulty/tier.
var race_difficulty: RaceType = RaceType.SLOW
var pull_difficulty: PullType = PullType.LOCAL

# Global State
var race_started: bool = false

func _ready() -> void:
	player_horse = HorseRegistry.instance("belgian")
