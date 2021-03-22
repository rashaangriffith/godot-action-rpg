extends Control

onready var team_1_percentage = $Team1Percentage
onready var team_2_percentage = $Team2Percentage
onready var status = $Status
onready var captured_team = $CapturedTeam

func _ready():
	ObjectiveState.connect("team_percentage_changed", self, "_on_ObjectiveState_team_percentage_changed")
	ObjectiveState.connect("objective_status_changed", self, "_on_ObjectiveState_status_changed")
	ObjectiveState.connect("captured_team_changed", self, "_on_ObjectiveState_captured_team_changed")

func _on_ObjectiveState_team_percentage_changed(team, value):
	if team == PlayerStats.TEAM1:
		team_1_percentage.text = str(value) + "%"
	elif team == PlayerStats.TEAM2:
		team_2_percentage.text = str(value) + "%"

func _on_ObjectiveState_status_changed(value):
	status.text = value

func _on_ObjectiveState_captured_team_changed(value):
	captured_team.text = str(value)
