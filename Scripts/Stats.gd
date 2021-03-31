extends Node

const TEAM1 = "1"
const TEAM2 = "2"

signal no_health
signal health_changed(value, player_id)
signal max_health_changed(value)
signal ammo_count_changed(remaining, maximum)
signal ap_count_changed(remaining, maximum)
signal ability_1_disabled(value)
signal ability_2_disabled(value)
signal super_meter_count_changed(value)

#func _ready():
	#self.health = max_health

func set_player_max_health(player_id, value):
	Server.players[int(player_id)]["MaxHealth"] = value
	Server.players[int(player_id)]["Health"] = value
	if player_id == Server.local_player_id:
		emit_signal("max_health_changed", value, player_id)
		emit_signal("health_changed", value)

func set_player_health(player_id, value):
	var max_health = Server.players[int(player_id)]["MaxHealth"]
	var health = min(value, max_health)
	Server.players[int(player_id)]["Health"] = value
	if player_id == Server.local_player_id:
		emit_signal("health_changed", health, player_id)
	if health <= 0:
		emit_signal("no_health", player_id)

func player_take_damage(player_id, value):
	var new_health = Server.players[int(player_id)]["Health"] - value
	set_player_health(player_id, new_health)

func reset_player(player_id):
	var new_health = Server.players[int(player_id)]["MaxHealth"]
	set_player_health(player_id, new_health)
		
func get_player_data(player_id, data_key):
	return Server.players[int(player_id)][data_key]
	
func set_player_data(player_id, data_key, data_value):
	Server.players[int(player_id)][data_key] = data_value

func is_same_team(player_id_1, player_id_2):
	return Server.players[int(player_id_1)]["Team"] == Server.players[int(player_id_2)]["Team"]
	
func set_ammo_count(remaining, maximum):
	emit_signal("ammo_count_changed", remaining, maximum)
	
func set_ap_count(value):
	emit_signal("ap_count_changed", value)

func set_ability_1_disabled(value):
	print("set ability 1 disabled: " + str(value))
	emit_signal("ability_1_disabled", value)

func set_ability_2_disabled(value):
	emit_signal("ability_2_disabled", value)

func set_super_meter_count(value):
	emit_signal("super_meter_count_changed", value)
