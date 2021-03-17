extends Node2D

const PLAYER_SCENE = preload("res://player/player.tscn")
const BAT_SCENE = preload("res://enemies/bat/bat.tscn")

var possible_enemy_destinations

onready var player_spawn = $WorldObjects/PlayerSpawn
onready var players = $WorldObjects/Players
onready var enemy_destinations = $WorldObjects/EnemySpawn
onready var enemies = $WorldObjects/Enemies

onready var team_1_spawns = $WorldObjects/Team1Spawns
onready var team_2_spawns = $WorldObjects/Team2Spawns

func _ready():
	possible_enemy_destinations = enemy_destinations.get_children()
	rpc_id(1, "spawn_players", Server.local_player_id)
	
remote func spawn_player(id):
	var player = PLAYER_SCENE.instance()
	player.name = str(id)
	player.player_id = id
	players.add_child(player)
	player.set_network_master(id)
	#player.position = player_spawn.position
	var team = PlayerStats.get_player_data(id, "Team")
	var player_number = PlayerStats.get_player_data(id, "Player_number")
	if team == "1":
		player.position = team_1_spawns.get_children()[player_number - 1].position
	elif team == "2":
		player.position = team_2_spawns.get_children()[player_number - 2].position
	player.spawn_position = player.position
	print("gamestate spawn_player: " + str(Server.players[int(id)]))

remote func spawn_enemy(index, name):
	var enemy_destination = possible_enemy_destinations[index]
	var enemy = BAT_SCENE.instance()
	enemy.name = name
	enemies.add_child(enemy)
	enemy.position = enemy_destination.position


func _on_EnemySpawnTimer_timeout():
	pass
	# don't spawn enemies for now
	#rpc_id(1, "spawn_enemies")
