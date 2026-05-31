extends Area2D

signal race_finished(winner_name: String)

var race_over: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if race_over:
		return
	race_over = true
	var winner = body
	emit_signal("race_finished", winner)
	
