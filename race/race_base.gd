class_name RaceBase
extends Node2D

## Shared base for every event type (Circuit Track, Harness Pull, and later
## Steeplechase). Holds the logic that's common across events so new race types
## reuse it instead of duplicating reward handling.

## Pay out money/experience for a finished event. `cfg` is an event config dict
## (e.g. Global.RACES[difficulty] or Global.PULLS[tier]) carrying the keys
## "reward_win", "exp_win" and "exp_lose". Returns the amounts awarded so the
## caller can show them in a results panel.
func award_results(player_won: bool, cfg: Dictionary) -> Dictionary:
	var exp_gained: int = cfg["exp_win"] if player_won else cfg["exp_lose"]
	var money_gained: int = cfg["reward_win"] if player_won else 0
	Global.money += money_gained
	Global.player_horse.experience += exp_gained
	return { "exp": exp_gained, "money": money_gained, "won": player_won }
