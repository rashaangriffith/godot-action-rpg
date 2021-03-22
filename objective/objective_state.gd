extends Node

signal team_percentage_changed(team, value)
signal objective_status_changed(value)
signal captured_team_changed(value)

func update_team_percentage(team, value):
	emit_signal("team_percentage_changed", team, value)

func update_objective_status(value):
	emit_signal("objective_status_changed", value)

func update_captured_team(value):
	emit_signal("captured_team_changed", value)
