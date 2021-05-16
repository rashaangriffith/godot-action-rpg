extends Area2D

enum OBJECTIVE_STATES {
	OPEN,
	CAPTURING,
	CAPTURED,
	CONTESTING,
	CAPTURED_CONTESTING,
	FLIPPING,
}

const WINNING_CAPTURE_PERCENTAGE = 100

onready var capturing_timer = $CapturingTimer
onready var captured_timer = $CapturedTimer
onready var captured_audio_player = $CapturedAudioPlayer

var state = OBJECTIVE_STATES.OPEN
var team_1_capturers = 0
var team_2_capturers = 0
var captured_team = null
var team_1_percentage = 0
var team_2_percentage = 0

func _ready():
	GameManager.connect("round_started", self, "_on_GameManager_start_round")

func start_round():
	state = OBJECTIVE_STATES.OPEN
	team_1_capturers = 0
	team_2_capturers = 0
	captured_team = null
	team_1_percentage = 0
	team_2_percentage = 0
	ObjectiveState.update_team_percentage(Server.TEAM1, 0)
	ObjectiveState.update_team_percentage(Server.TEAM2, 0)
	ObjectiveState.update_objective_status("open")
	ObjectiveState.update_captured_team("")

func end_round(winning_team):
	capturing_timer.stop()
	captured_timer.stop()
	GameManager.end_round(winning_team)

func update_capturers(team, number):
	if team == Server.TEAM1:
		team_1_capturers += number
	elif team == Server.TEAM2:
		team_2_capturers += number
		
	print('capturers: team1: ' + str(team_1_capturers) + ' | team2: ' + str(team_2_capturers))

func is_other_team_capturing(team):
	if team == Server.TEAM1 && team_2_capturers > 0:
		return true
	elif team == Server.TEAM2 && team_1_capturers > 0:
		return true
	
	return false
	
func is_my_team_capturing(team):
	if team == Server.TEAM1 && team_1_capturers > 0:
		return true
	elif team == Server.TEAM2 && team_2_capturers > 0:
		return true
	
	return false

func has_other_team_captured(team):
	if team == Server.TEAM1 && captured_team == Server.TEAM2:
		return true
	elif team == Server.TEAM2 && captured_team == Server.TEAM1:
		return true
		
	return false

func has_my_team_captured(team):
	if team == Server.TEAM1 && captured_team == Server.TEAM1:
		return true
	elif team == Server.TEAM2 && captured_team == Server.TEAM2:
		return true
		
	return false
		
func get_other_team(team):
	if team == Server.TEAM1:
		return Server.TEAM2
	elif team == Server.TEAM2:
		return Server.TEAM1

func _on_Objective_body_entered(body):
	print(str(body.get_name()) + ' entered the objective')
	
	if not GameManager.is_in_game_state():
		print("not in gamestate... ignore")
		return
	
	var team = PlayerStats.get_player_data(body.player_id, "Team")
	update_capturers(team, 1)
	
	match state:
		OBJECTIVE_STATES.OPEN:
			capturing_timer.start()
			state = OBJECTIVE_STATES.CAPTURING
			print('objective state: team ' + str(team) + ' is capturing...')
			ObjectiveState.update_objective_status('team ' + str(team) + ' is capturing...')
		OBJECTIVE_STATES.CAPTURING:
			if is_other_team_capturing(team):
				state = OBJECTIVE_STATES.CONTESTING
				print('objective state: contesting...')
				ObjectiveState.update_objective_status("contesting...")
				capturing_timer.stop()
		OBJECTIVE_STATES.CAPTURED:
			if has_other_team_captured(team):
				state = OBJECTIVE_STATES.CAPTURED_CONTESTING
				print('objective state: captured contesting...')
				ObjectiveState.update_objective_status("captured contesting...")
		OBJECTIVE_STATES.FLIPPING:
			if is_other_team_capturing(team):
				capturing_timer.stop()
				state = OBJECTIVE_STATES.CAPTURED_CONTESTING
				print('objective state: captured contesting...')
				ObjectiveState.update_objective_status("captured contesting...")

func _on_Objective_body_exited(body):
	print(str(body.get_name()) + ' exited the objective')
	
	if not GameManager.is_in_game_state():
		print("not in gamestate... ignore")
		return
	
	var team = PlayerStats.get_player_data(body.player_id, "Team")
	update_capturers(team, -1)
	
	match state:
		OBJECTIVE_STATES.CAPTURING:
			if not is_my_team_capturing(team):
				capturing_timer.stop()
				state = OBJECTIVE_STATES.OPEN
				print('objective state: open')
				ObjectiveState.update_objective_status("open")
		OBJECTIVE_STATES.CONTESTING:
			if not is_my_team_capturing(team) && is_other_team_capturing(team):
				capturing_timer.start()
				state = OBJECTIVE_STATES.CAPTURING
				print('objective state: team ' + str(get_other_team(team)) + ' is capturing...')
				ObjectiveState.update_objective_status('team ' + str(get_other_team(team)) + ' is capturing...')
		OBJECTIVE_STATES.CAPTURED_CONTESTING:
			if has_other_team_captured(team) && not is_my_team_capturing(team):
				state = OBJECTIVE_STATES.CAPTURED
				captured_audio_player.play()
				print('objective state: team ' + str(get_other_team(team)) + ' has still captured')
				ObjectiveState.update_objective_status('team ' + str(get_other_team(team)) + ' has still captured')
			elif has_my_team_captured(team) && not is_my_team_capturing(team) && is_other_team_capturing(team):
				state = OBJECTIVE_STATES.FLIPPING
				capturing_timer.start()
				print('objective state: team ' + str(get_other_team(team)) + ' is capturing...')
				ObjectiveState.update_objective_status('team ' + str(get_other_team(team)) + ' is capturing...')
		OBJECTIVE_STATES.FLIPPING:
			if not is_my_team_capturing(team):
				state = OBJECTIVE_STATES.CAPTURED
				captured_audio_player.play()
				print('stopped flipping: team ' + str(get_other_team(team)) + ' has still captured')
				ObjectiveState.update_objective_status('team ' + str(get_other_team(team)) + ' has still captured')
				capturing_timer.stop()

func _on_CapturingTimer_timeout():
	capturing_timer.stop()
	if team_1_capturers > 0:
		captured_team = Server.TEAM1
		state = OBJECTIVE_STATES.CAPTURED
		captured_audio_player.play()
		print('objective state: team 1 has captured')
		ObjectiveState.update_objective_status("team 1 has captured")
		ObjectiveState.update_captured_team(Server.TEAM1)
	elif team_2_capturers > 0:
		captured_team = Server.TEAM2
		state = OBJECTIVE_STATES.CAPTURED
		captured_audio_player.play()
		print('objective state: team 2 has captured')
		ObjectiveState.update_objective_status("team 2 has captured")
		ObjectiveState.update_captured_team(Server.TEAM2)
	captured_timer.start()

func _on_CapturedTimer_timeout():
	if captured_team == Server.TEAM1:
		team_1_percentage += 1
		ObjectiveState.update_team_percentage(Server.TEAM1, team_1_percentage)
		if (team_1_percentage == WINNING_CAPTURE_PERCENTAGE):
			GameManager.add_to_score(1, 0)
			end_round(Server.TEAM1)
	elif captured_team == Server.TEAM2:
		team_2_percentage += 1
		ObjectiveState.update_team_percentage(Server.TEAM2, team_2_percentage)
		if (team_2_percentage == WINNING_CAPTURE_PERCENTAGE):
			GameManager.add_to_score(0, 1)
			end_round(Server.TEAM2)
	
#	print('score - team1: ' + str(team_1_percentage) + " | team2: " + str(team_2_percentage))

func _on_GameManager_start_round(current_round):
	start_round()
