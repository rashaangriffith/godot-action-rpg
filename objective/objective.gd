extends Area2D

enum OBJECTIVE_STATES {
	OPEN,
	CAPTURING,
	CAPTURED,
	CONTESTING,
	CAPTURED_CONTESTING,
	FLIPPING,
}

onready var capturingTimer = $CapturingTimer
onready var capturedTimer = $CapturedTimer

var state = OBJECTIVE_STATES.OPEN
var team1Capturers = 0
var team2Capturers = 0
var capturedTeam = null
var team1Percentage = 0
var team2Percentage = 0

func update_capturers(team, number):
	if team == PlayerStats.TEAM1:
		team1Capturers += number
	elif team == PlayerStats.TEAM2:
		team2Capturers += number
		
	print('capturers: team1: ' + str(team1Capturers) + ' | team2: ' + str(team2Capturers))

func is_other_team_capturing(team):
	if team == PlayerStats.TEAM1 && team2Capturers > 0:
		return true
	elif team == PlayerStats.TEAM2 && team1Capturers > 0:
		return true
	
	return false
	
func is_my_team_capturing(team):
	if team == PlayerStats.TEAM1 && team1Capturers > 0:
		return true
	elif team == PlayerStats.TEAM2 && team2Capturers > 0:
		return true
	
	return false

func has_other_team_captured(team):
	if team == PlayerStats.TEAM1 && capturedTeam == PlayerStats.TEAM2:
		return true
	elif team == PlayerStats.TEAM2 && capturedTeam == PlayerStats.TEAM1:
		return true
		
	return false

func has_my_team_captured(team):
	if team == PlayerStats.TEAM1 && capturedTeam == PlayerStats.TEAM1:
		return true
	elif team == PlayerStats.TEAM2 && capturedTeam == PlayerStats.TEAM2:
		return true
		
	return false
		
func get_other_team(team):
	if team == PlayerStats.TEAM1:
		return PlayerStats.TEAM2
	elif team == PlayerStats.TEAM2:
		return PlayerStats.TEAM1

func _on_Objective_body_entered(body):
	print(str(body.get_name()) + ' entered the objective')
	
	var team = PlayerStats.get_player_data(body.player_id, "Team")
	update_capturers(team, 1)
	
	match state:
		OBJECTIVE_STATES.OPEN:
			capturingTimer.start()
			state = OBJECTIVE_STATES.CAPTURING
			print('objective state: team ' + str(team) + ' is capturing...')
			ObjectiveState.update_objective_status('team ' + str(team) + ' is capturing...')
		OBJECTIVE_STATES.CAPTURING:
			if is_other_team_capturing(team):
				state = OBJECTIVE_STATES.CONTESTING
				print('objective state: contesting...')
				ObjectiveState.update_objective_status("contesting...")
				capturingTimer.stop()
		OBJECTIVE_STATES.CAPTURED:
			if has_other_team_captured(team):
				state = OBJECTIVE_STATES.CAPTURED_CONTESTING
				print('objective state: captured contesting...')
				ObjectiveState.update_objective_status("captured contesting...")
		OBJECTIVE_STATES.FLIPPING:
			if is_other_team_capturing(team):
				capturingTimer.stop()
				state = OBJECTIVE_STATES.CAPTURED_CONTESTING
				print('objective state: captured contesting...')
				ObjectiveState.update_objective_status("captured contesting...")

func _on_Objective_body_exited(body):
	print(str(body.get_name()) + ' exited the objective')
	
	var team = PlayerStats.get_player_data(body.player_id, "Team")
	update_capturers(team, -1)
	
	match state:
		OBJECTIVE_STATES.CAPTURING:
			if not is_my_team_capturing(team):
				capturingTimer.stop()
				state = OBJECTIVE_STATES.OPEN
				print('objective state: open')
				ObjectiveState.update_objective_status("open")
		OBJECTIVE_STATES.CONTESTING:
			if not is_my_team_capturing(team) && is_other_team_capturing(team):
				capturingTimer.start()
				state = OBJECTIVE_STATES.CAPTURING
				print('objective state: team ' + str(get_other_team(team)) + ' is capturing...')
				ObjectiveState.update_objective_status('team ' + str(get_other_team(team)) + ' is capturing...')
		OBJECTIVE_STATES.CAPTURED_CONTESTING:
			if has_other_team_captured(team) && not is_my_team_capturing(team):
				state = OBJECTIVE_STATES.CAPTURED
				print('objective state: team ' + str(get_other_team(team)) + ' has still captured')
				ObjectiveState.update_objective_status('team ' + str(get_other_team(team)) + ' has still captured')
			elif has_my_team_captured(team) && not is_my_team_capturing(team) && is_other_team_capturing(team):
				state = OBJECTIVE_STATES.FLIPPING
				capturingTimer.start()
				print('objective state: team ' + str(get_other_team(team)) + ' is capturing...')
				ObjectiveState.update_objective_status('team ' + str(get_other_team(team)) + ' is capturing...')
		OBJECTIVE_STATES.FLIPPING:
			if not is_my_team_capturing(team):
				state = OBJECTIVE_STATES.CAPTURED
				print('stopped flipping: team ' + str(get_other_team(team)) + ' has still captured')
				ObjectiveState.update_objective_status('team ' + str(get_other_team(team)) + ' has still captured')
				capturingTimer.stop()

func _on_CapturingTimer_timeout():
	capturingTimer.stop()
	if team1Capturers > 0:
		capturedTeam = PlayerStats.TEAM1
		state = OBJECTIVE_STATES.CAPTURED
		print('objective state: team 1 has captured')
		ObjectiveState.update_objective_status("team 1 has captured")
		ObjectiveState.update_captured_team(PlayerStats.TEAM1)
	elif team2Capturers > 0:
		capturedTeam = PlayerStats.TEAM2
		state = OBJECTIVE_STATES.CAPTURED
		print('objective state: team 2 has captured')
		ObjectiveState.update_objective_status("team 2 has captured")
		ObjectiveState.update_captured_team(PlayerStats.TEAM2)
	capturedTimer.start()

func _on_CapturedTimer_timeout():
	if capturedTeam == PlayerStats.TEAM1:
		team1Percentage += 1
		ObjectiveState.update_team_percentage(PlayerStats.TEAM1, team1Percentage)
	elif capturedTeam == PlayerStats.TEAM2:
		team2Percentage += 1
		ObjectiveState.update_team_percentage(PlayerStats.TEAM2, team2Percentage)
	print('score - team1: ' + str(team1Percentage) + " | team2: " + str(team2Percentage))
