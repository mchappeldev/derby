extends Node

enum RaceType { SLOW, QUICK, FAST }

const RACES = {
	RaceType.SLOW:  { "cost": 0,   "npc_speed": 10, "reward_win": 25,   "exp_win": 2,  "exp_lose": 1 },
	RaceType.QUICK: { "cost": 50,  "npc_speed": 20, "reward_win": 150,  "exp_win": 5,  "exp_lose": 2 },
	RaceType.FAST:  { "cost": 500, "npc_speed": 30, "reward_win": 1000, "exp_win": 10, "exp_lose": 3 },
}

#Horse Stats
var speed: int = 10
var endurance: int = 10
var jump: int = 10
var experience: int = 0
var race_difficulty: RaceType = RaceType.SLOW

#Player Stats
var money: int = 0

func _ready() -> void:
	pass
