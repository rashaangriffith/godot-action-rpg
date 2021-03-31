extends Node2D

const MAX_HEALTH = 4

onready var name_label = $NameLabel
onready var health_full = $HeathFull

var player_id

func _ready():
	PlayerStats.connect("health_changed", self, "_on_PlayerStats_health_changed")

func set_name_label(name, player_id):
	name_label.text = name
	var my_team_color = Color(0.25, 0.88, 0.82, 1)
	var other_team_color = Color(1, 0, 0, 1)
	if PlayerStats.is_same_team(Server.local_player_id, player_id):
		name_label.add_color_override("font_color", my_team_color)
	else:
		name_label.add_color_override("font_color", other_team_color)

func _on_PlayerStats_health_changed(value, _player_id):
	if player_id == _player_id:
		var health = clamp(value, 0 , MAX_HEALTH)
		if (health_full != null):
			health_full.rect_size.x = health * 15
