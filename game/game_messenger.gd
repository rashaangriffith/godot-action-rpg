extends Control

onready var big_label = $BigLabel
onready var big_countdown = $BigCountdown
onready var small_label = $SmallLabel
onready var small_countdown = $SmallCountdown

var current_round = 1

func _ready():
	GameManager.connect("time_changed", self, "_on_GameManager_time_changed")
	GameManager.connect("round_started", self, "_on_GameManager_round_started")
	GameManager.connect("round_game_started", self, "_on_GameManager_round_game_started")
	GameManager.connect("post_round_started", self, "_on_GameManager_post_round_started")
	GameManager.connect("match_ended", self, "_on_GameManager_match_ended")
	# hide labels

func _on_GameManager_time_changed(time, game_state):
	big_countdown.text = str(time)
	small_countdown.text = str(time)

func _on_GameManager_round_started(rnd):
	current_round = rnd
	var message = "Round " + str(rnd) + " starts in"
	big_label.text = message
	
func _on_GameManager_round_game_started():
	remove_child(big_label)
	remove_child(big_countdown)

func _on_GameManager_post_round_started(winning_team):
	var message = "Team " + str(winning_team) + " wins rd " + str(current_round) + ". Next in"
	big_label.text = message
	add_child(big_label)
	add_child(big_countdown)

func _on_GameManager_match_ended(winning_team):
	var message = "Team " + str(winning_team) + " wins!"
	big_label.text = message
	add_child(big_label)
	add_child(big_countdown)
