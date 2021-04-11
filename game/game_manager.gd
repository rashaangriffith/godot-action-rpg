extends Node

enum GAME_STATES {
	PRE_ROUND,
	GAME,
	POST_ROUND,
	END_MATCH,
}

signal time_changed(time, game_state)
signal round_started(current_round)
signal round_game_started()
signal round_game_ended()
signal post_round_started(winning_team)
signal team_score_changed(team1, team2)
signal match_ended(winning_team)
signal player_killed(killer_id, killed_id)
signal killed_player(killer_id, killed_id)
signal last_damaged(player_id, damaged_id)

const PRE_ROUND_TIME = 10
const POST_ROUND_TIME = 5
const WINNING_SCORE = 3

var state = GAME_STATES.PRE_ROUND
var state_timer
var time_left = 0
var team_1_score = 0
var team_2_score = 0

func _ready():
	state_timer = Timer.new()
	state_timer.wait_time = 1
	state_timer.connect("timeout", self, "_on_state_timer_timeout")
	add_child(state_timer)
	print("gm state: PRE_ROUND")

func _on_state_timer_timeout():
	time_left -= 1
	emit_signal("time_changed", time_left, state)
	
	if time_left == 0:
		match state:
			GAME_STATES.PRE_ROUND:
				state_timer.stop()
				state = GAME_STATES.GAME
				emit_signal("round_game_started")
				print("gm state: GAME")
			GAME_STATES.POST_ROUND:
				start_round()
	
	print("gm state: " + str(state) + " | time left: " + str(time_left))

func get_current_round():
	return team_1_score + team_2_score + 1

func start_round():
	state = GAME_STATES.PRE_ROUND
	print("gm state: PRE_ROUND")
	time_left = PRE_ROUND_TIME
	emit_signal("time_changed", time_left, state)
	state_timer.start()
	var current_round = get_current_round()
	emit_signal("round_started", current_round)

func add_to_score(team1, team2):
	team_1_score += team1
	team_2_score += team2
	emit_signal("team_score_changed", team_1_score, team_2_score)
	
func end_round(winning_team):
	emit_signal("round_game_ended")
	if team_1_score == WINNING_SCORE:
		end_match(PlayerStats.TEAM1)
	elif team_2_score == WINNING_SCORE:
		end_match(PlayerStats.TEAM2)
	else:
		state = GAME_STATES.POST_ROUND
		print("gm state: POST_ROUND")
		time_left = POST_ROUND_TIME
		emit_signal("time_changed", time_left, state)
		state_timer.start()
		emit_signal("post_round_started", winning_team)
	
func end_match(winning_team):
	state_timer.stop()
	state = GAME_STATES.END_MATCH
	emit_signal("match_ended", winning_team)
	print("gm state: END")

func is_in_game_state():
	return state == GAME_STATES.GAME

func player_killed(killer_id, killed_id):
	emit_signal("player_killed", killer_id, killed_id)
	
func killed_player(killer_id, killed_id):
	emit_signal("killed_player", killer_id, killed_id)

func set_last_damaged(player_id, damaged_id):
	emit_signal("last_damaged", player_id, damaged_id)
