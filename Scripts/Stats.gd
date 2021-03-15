extends Node

signal no_health
signal health_changed(value)
signal max_health_changed(value)

#func _ready():
	#self.health = max_health

func set_player_max_health(player_id, value):
	Server.players[int(player_id)]["MaxHealth"] = value
	Server.players[int(player_id)]["Health"] = value
	emit_signal("max_health_changed", value)

func set_player_health(player_id, value):
	var max_health = Server.players[int(player_id)]["MaxHealth"]
	var health = min(value, max_health)
	Server.players[int(player_id)]["Health"] = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func player_take_damage(player_id, value):
	var new_health = Server.players[int(player_id)]["Health"] - value
	set_player_health(player_id, new_health)
		
func get_player_data(player_id, data_key):
	return Server.players[int(player_id)][data_key]
	
func set_player_data(player_id, data_key, data_value):
	Server.players[int(player_id)][data_key] = data_value

func is_same_team(player_id_1, player_id_2):
	return Server.players[int(player_id_1)]["Team"] == Server.players[int(player_id_2)]["Team"]
