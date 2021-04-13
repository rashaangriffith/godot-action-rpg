extends Popup

onready var team1_list = $CenterContainer/VBoxContainer/HBoxContainer/Team1/ItemList
onready var team2_list = $CenterContainer/VBoxContainer/HBoxContainer/Team2/ItemList

func _ready():
	team1_list.clear()
	team2_list.clear()
	
func refresh_players(players):
	team1_list.clear()
	team2_list.clear()
	for player_id in players:
		var player = players[player_id]["Player_name"]
		if players[player_id]["Team"] == Server.TEAM1:
			team1_list.add_item(player, null, false)
		elif players[player_id]["Team"] == Server.TEAM2:
			team2_list.add_item(player, null, false)
