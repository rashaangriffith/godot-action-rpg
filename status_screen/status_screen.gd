extends Control

onready var player_name = $CenterContainer/VBoxContainer/Info/PlayerStats/PlayerName
onready var kills = $CenterContainer/VBoxContainer/Info/PlayerStats/Kills
onready var deaths = $CenterContainer/VBoxContainer/Info/PlayerStats/Deaths
onready var team1_list = $CenterContainer/VBoxContainer/Teams/Team1/Team1List
onready var team2_list = $CenterContainer/VBoxContainer/Teams/Team2/Team2List

func _ready():
	player_name.text = PlayerStats.get_player_name(Server.local_player_id)
	kills.text = "kills: 0"
	deaths.text = "deaths: 0"
	team1_list.clear()
	team2_list.clear()
	var players = Server.players
	for player_id in players:
		var player = players[player_id]["Player_name"]
		if players[player_id]["Team"] == Server.TEAM1:
			team1_list.add_item(player, null, false)
		elif players[player_id]["Team"] == Server.TEAM2:
			team2_list.add_item(player, null, false)
	
	PlayerStats.connect("kills_count_changed", self, "_on_PlayerStats_kills_count_changed")
	PlayerStats.connect("deaths_count_changed", self, "_on_PlayerStats_deaths_count_changed")
	

func _process(delta):
	if Input.is_action_pressed("status"):
		visible = true
	else:
		visible = false

func update_kills(value):
	kills.text = "kills: " + str(value)

func update_deaths(value):
	deaths.text = "deaths: " + str(value)
	
func _on_PlayerStats_kills_count_changed(value):
	update_kills(value)
	
func _on_PlayerStats_deaths_count_changed(value):
	update_deaths(value)
