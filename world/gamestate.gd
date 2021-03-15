extends Node2D

const PLAYER_SCENE = preload("res://player/player.tscn")
const BAT_SCENE = preload("res://enemies/bat/bat.tscn")

var possible_enemy_destinations

onready var player_spawn = $WorldObjects/PlayerSpawn
onready var players = $WorldObjects/Players
onready var enemy_destinations = $WorldObjects/EnemySpawn
onready var enemies = $WorldObjects/Enemies

func _ready():
	possible_enemy_destinations = enemy_destinations.get_children()
	rpc_id(1, "spawn_players", Server.local_player_id)
	
remote func spawn_player(id):
	var player = PLAYER_SCENE.instance()
	player.name = str(id)
	player.player_id = id
	players.add_child(player)
	player.set_network_master(id)
	player.position = player_spawn.position

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
