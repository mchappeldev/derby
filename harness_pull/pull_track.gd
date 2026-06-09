extends RaceBase

## Harness Pull: a turn-based, rock-paper-scissors / Pokemon-style battle between
## the player's horse and an enemy horse. Each turn both horses pick a move; the
## pairing decides who drags their load closer home (distance_remaining -> 0 wins).
## Pull/Brace spend endurance, Rest recovers it, and running dry forces skips.

# --- Tunables -------------------------------------------------------------
const START_DISTANCE := 100.0      # full "distance remaining" bar
const BASE_GAIN := 12.0            # ground a horse gains on a won exchange
const SLACK_SLIP := 8.0            # ground lost when slack goes uncontested / double-slack
const TIRE_PENALTY := 4.0          # ground a puller loses when the opponent braces
const TRIP_PENALTY := 4.0          # ground a bracer loses when the opponent gives slack
const PULL_VS_SLACK_MULT := 2.0    # puller lunges this much further vs a slacker
const CHOICE_SECONDS := 5.0        # time to pick a move before the turn is forfeit
const REST_GAIN := 2               # endurance recovered by a voluntary Rest
const EXHAUST_SKIPS := 2           # forced skip turns after endurance hits 0
const PIX_PER_UNIT := 1.4          # sprite slide per unit of ground gained
const RESOLVE_PAUSE := 1.0         # seconds to read the outcome before the next turn

enum Move { PULL, BRACE, SLACK, REST, SKIP, TIMEOUT }

enum State { CHOOSING, RESOLVING, FINISHED }

const PULL_HORSE := preload("res://harness_pull/pull_horse.tscn")

@onready var player_dist_bar: ProgressBar = $Ui/Control/Top/PlayerPanel/DistBar
@onready var enemy_dist_bar: ProgressBar = $Ui/Control/Top/EnemyPanel/DistBar
@onready var player_name_label: Label = $Ui/Control/Top/PlayerPanel/NameLabel
@onready var enemy_name_label: Label = $Ui/Control/Top/EnemyPanel/NameLabel
@onready var player_end_label: Label = $Ui/Control/Top/PlayerPanel/EnduranceLabel
@onready var enemy_end_label: Label = $Ui/Control/Top/EnemyPanel/EnduranceLabel
@onready var status_label: Label = $Ui/Control/Center/StatusLabel
@onready var timer_bar: ProgressBar = $Ui/Control/Center/TimerBar
@onready var pull_button: Button = $Ui/Control/Moves/PullButton
@onready var brace_button: Button = $Ui/Control/Moves/BraceButton
@onready var slack_button: Button = $Ui/Control/Moves/SlackButton
@onready var rest_button: Button = $Ui/Control/Moves/RestButton
@onready var results_panel: Control = $Ui/Control/Results
@onready var results_label: Label = $Ui/Control/Results/VBox/ResultsLabel
@onready var back_button: Button = $Ui/Control/Results/VBox/BackButton
@onready var choice_timer: Timer = $ChoiceTimer

var player_node: pull_horse
var enemy_node: pull_horse
var state: int = State.RESOLVING

var player_move: int = -1
var enemy_move: int = -1

var rng := RandomNumberGenerator.new()
var center_x: float
var horse_y: float

func _ready() -> void:
	rng.randomize()
	var cfg: Dictionary = Global.PULLS[Global.pull_difficulty]

	var view := get_viewport_rect().size
	center_x = view.x * 0.5
	horse_y = view.y * 0.55

	# Player horse (left, dragging toward the left edge).
	player_node = PULL_HORSE.instantiate()
	player_node.setup(Global.player_horse, true, START_DISTANCE)
	add_child(player_node)
	player_node.position = Vector2(center_x - 40, horse_y)

	# Enemy horse (right, dragging toward the right edge).
	var enemy_data: HorseData = HorseRegistry.instance(cfg["npc_breed"])
	enemy_data.display_name = "Rival"
	enemy_data.strength = cfg["npc_strength"]
	enemy_data.endurance = cfg["npc_endurance"]
	enemy_node = PULL_HORSE.instantiate()
	enemy_node.setup(enemy_data, false, START_DISTANCE)
	add_child(enemy_node)
	enemy_node.position = Vector2(center_x + 40, horse_y)

	player_name_label.text = Global.player_horse.display_name
	enemy_name_label.text = enemy_data.display_name
	for bar in [player_dist_bar, enemy_dist_bar]:
		bar.max_value = START_DISTANCE
		bar.value = START_DISTANCE
	timer_bar.max_value = CHOICE_SECONDS

	pull_button.pressed.connect(_on_move_selected.bind(Move.PULL))
	brace_button.pressed.connect(_on_move_selected.bind(Move.BRACE))
	slack_button.pressed.connect(_on_move_selected.bind(Move.SLACK))
	rest_button.pressed.connect(_on_move_selected.bind(Move.REST))
	choice_timer.timeout.connect(_on_choice_timeout)
	back_button.pressed.connect(_on_back_pressed)

	results_panel.visible = false
	_refresh_hud()
	begin_turn()

func _process(_delta: float) -> void:
	# Drain the choice-timer bar while the player is deciding.
	if state == State.CHOOSING:
		timer_bar.value = choice_timer.time_left
	else:
		timer_bar.value = 0.0

# --- Turn flow ------------------------------------------------------------

func begin_turn() -> void:
	if state == State.FINISHED:
		return
	player_move = -1
	enemy_move = -1
	_refresh_hud()

	if player_node.exhaust_skips_left > 0:
		# Forced to recover — the player can't act this turn.
		state = State.RESOLVING
		_set_moves_enabled(false)
		status_label.text = "Your horse is exhausted — skipping to catch its breath!"
		player_move = Move.SKIP
		await get_tree().create_timer(0.8).timeout
		_resolve_turn()
		return

	state = State.CHOOSING
	_set_moves_enabled(true)
	status_label.text = "Choose your move! (%d seconds)" % int(CHOICE_SECONDS)
	choice_timer.start(CHOICE_SECONDS)

func _on_move_selected(move: int) -> void:
	if state != State.CHOOSING:
		return
	player_move = move
	_resolve_turn()

func _on_choice_timeout() -> void:
	if state != State.CHOOSING:
		return
	# Hesitation: the player forfeits the turn and the rival gets a free pull.
	player_move = Move.TIMEOUT
	_resolve_turn()

func _resolve_turn() -> void:
	state = State.RESOLVING
	choice_timer.stop()
	_set_moves_enabled(false)

	enemy_move = _pick_enemy_move()

	# Endurance is spent/recovered before movement is worked out.
	_apply_endurance_cost(player_node, player_move)
	_apply_endurance_cost(enemy_node, enemy_move)

	var deltas := _move_delta_pair(player_move, enemy_move)
	player_node.distance_remaining = clampf(player_node.distance_remaining + deltas[0], 0.0, START_DISTANCE)
	enemy_node.distance_remaining = clampf(enemy_node.distance_remaining + deltas[1], 0.0, START_DISTANCE)

	status_label.text = _describe_outcome(player_move, enemy_move)
	_animate_to_state()
	_refresh_hud()

	await get_tree().create_timer(RESOLVE_PAUSE).timeout
	if _check_for_winner():
		return
	begin_turn()

# --- Enemy AI -------------------------------------------------------------

func _pick_enemy_move() -> int:
	# A timed-out player hands the rival a guaranteed free pull.
	if player_move == Move.TIMEOUT:
		return Move.PULL
	if enemy_node.exhaust_skips_left > 0:
		return Move.SKIP
	var legal := [Move.SLACK, Move.REST]
	if enemy_node.endurance_left >= 1:
		legal.append(Move.PULL)
		legal.append(Move.BRACE)
	return legal[rng.randi_range(0, legal.size() - 1)]

# --- Endurance ------------------------------------------------------------

func _apply_endurance_cost(horse: pull_horse, move: int) -> void:
	match move:
		Move.PULL, Move.BRACE:
			horse.endurance_left -= 1
			if horse.endurance_left <= 0:
				horse.endurance_left = 0
				horse.exhaust_skips_left = EXHAUST_SKIPS
		Move.REST:
			horse.endurance_left = min(horse.data.endurance, horse.endurance_left + REST_GAIN)
		Move.SKIP:
			# Forced recovery skip: regain a little, burn down the penalty.
			horse.endurance_left = min(horse.data.endurance, horse.endurance_left + 1)
			horse.exhaust_skips_left = max(0, horse.exhaust_skips_left - 1)
		Move.SLACK, Move.TIMEOUT:
			pass

# --- Movement resolution --------------------------------------------------

func _strength_factor(horse: pull_horse) -> float:
	return 1.0 + max(0, horse.data.strength - 10) * 0.04

func _gain(horse: pull_horse) -> float:
	return BASE_GAIN * _strength_factor(horse)

func _is_inert(move: int) -> bool:
	return move == Move.REST or move == Move.SKIP or move == Move.TIMEOUT

## Returns [player_delta, enemy_delta] applied to distance_remaining
## (negative = gain ground toward winning, positive = lose ground).
func _move_delta_pair(p_move: int, e_move: int) -> Array:
	var p_inert := _is_inert(p_move)
	var e_inert := _is_inert(e_move)
	if p_inert and e_inert:
		return [0.0, 0.0]
	if p_inert:
		return [0.0, _solo_delta(e_move, enemy_node)]
	if e_inert:
		return [_solo_delta(p_move, player_node), 0.0]
	return _contest_pair(p_move, e_move)

## Delta for a contesting horse whose opponent did nothing (rest/skip/timeout).
func _solo_delta(move: int, horse: pull_horse) -> float:
	match move:
		Move.PULL:
			return -_gain(horse)   # free pull
		Move.SLACK:
			return SLACK_SLIP      # reversed for nothing, slips back
		_:
			return 0.0             # an unopposed brace does nothing

## Delta pair when both horses contest. p = player, e = enemy.
func _contest_pair(p_move: int, e_move: int) -> Array:
	match [p_move, e_move]:
		[Move.PULL, Move.PULL], [Move.BRACE, Move.BRACE]:
			return [0.0, 0.0]
		[Move.SLACK, Move.SLACK]:
			return [SLACK_SLIP, SLACK_SLIP]
		[Move.PULL, Move.BRACE]:
			return [TIRE_PENALTY, -_gain(enemy_node)]
		[Move.BRACE, Move.PULL]:
			return [-_gain(player_node), TIRE_PENALTY]
		[Move.BRACE, Move.SLACK]:
			return [TRIP_PENALTY, -_gain(enemy_node)]
		[Move.SLACK, Move.BRACE]:
			return [-_gain(player_node), TRIP_PENALTY]
		[Move.PULL, Move.SLACK]:
			return [-_gain(player_node) * PULL_VS_SLACK_MULT, 0.0]
		[Move.SLACK, Move.PULL]:
			return [0.0, -_gain(enemy_node) * PULL_VS_SLACK_MULT]
	return [0.0, 0.0]

# --- Presentation ---------------------------------------------------------

func _move_name(move: int) -> String:
	match move:
		Move.PULL: return "pulled"
		Move.BRACE: return "braced"
		Move.SLACK: return "gave slack"
		Move.REST: return "rested"
		Move.SKIP: return "was too exhausted to act"
		Move.TIMEOUT: return "hesitated"
		_: return "waited"

func _describe_outcome(p_move: int, e_move: int) -> String:
	return "You %s. The rival %s." % [_move_name(p_move), _move_name(e_move)]

func _animate_to_state() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(player_dist_bar, "value", player_node.distance_remaining, 0.4)
	tween.tween_property(enemy_dist_bar, "value", enemy_node.distance_remaining, 0.4)
	# Player drags its load toward the left edge, the rival toward the right.
	var p_x := center_x - 40 - (START_DISTANCE - player_node.distance_remaining) * PIX_PER_UNIT
	var e_x := center_x + 40 + (START_DISTANCE - enemy_node.distance_remaining) * PIX_PER_UNIT
	tween.tween_property(player_node, "position:x", p_x, 0.4)
	tween.tween_property(enemy_node, "position:x", e_x, 0.4)

func _refresh_hud() -> void:
	player_dist_bar.value = player_node.distance_remaining
	enemy_dist_bar.value = enemy_node.distance_remaining
	player_end_label.text = "Endurance: %d/%d" % [player_node.endurance_left, player_node.data.endurance]
	enemy_end_label.text = "Endurance: %d/%d" % [enemy_node.endurance_left, enemy_node.data.endurance]

func _set_moves_enabled(enabled: bool) -> void:
	# Pull/Brace also need at least one point of endurance to use.
	var has_endurance := player_node.endurance_left >= 1
	pull_button.disabled = not (enabled and has_endurance)
	brace_button.disabled = not (enabled and has_endurance)
	slack_button.disabled = not enabled
	rest_button.disabled = not enabled

# --- End of battle --------------------------------------------------------

func _check_for_winner() -> bool:
	var player_won := player_node.has_won()
	var enemy_won := enemy_node.has_won()
	if not player_won and not enemy_won:
		return false
	state = State.FINISHED
	_set_moves_enabled(false)
	var result := award_results(player_won, Global.PULLS[Global.pull_difficulty])
	var headline := "You won the pull!" if player_won else "The rival out-pulled you."
	results_label.text = "%s\nMoney gained: %d\nExperience gained: %d" % [headline, result["money"], result["exp"]]
	results_panel.visible = true
	return true

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://stable/stable.tscn")
