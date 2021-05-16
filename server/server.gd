extends Node

signal connection_status_changed(message)

const DEFAULT_IP: String = "34.75.90.9"
#const DEFAULT_IP: String = "127.0.0.1"
const DEFAULT_PORT: int = 9000
const TEAM1: int = 1
const TEAM2: int = 2

var network = NetworkedMultiplayerENet.new()
var selected_ip: String = DEFAULT_IP
var selected_port: int = DEFAULT_PORT

var local_player_id: int = 0
sync var players = {}
sync var player_data = {}
sync var next_player_team_number = TEAM1

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	_connect_to_server()

func _connect_to_server():
	emit_signal("connection_status_changed", "CONNECTING...")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	network.create_client(selected_ip, selected_port)
	get_tree().set_network_peer(network)

func _player_connected(id):
	print("Player: " + str(id) + " Connected")
	
func _player_disconnected(id):
	print("Player: " + str(id) + " Disconnected")
	
func _connected_ok():
	print("Successfully Connected")
	emit_signal("connection_status_changed", "CONNECTED!")
#	register_player()
#	print(str(local_player_id) + " _connected_ok, next_player_team_number: " + str(next_player_team_number))
#	rpc_id(1, "send_player_info", local_player_id, player_data)
	
func _connected_fail():
	emit_signal("connection_status_changed", "CONNECTION FAILED!")
	print("Connection Failed")
	
func _server_disconnected():
	print("Server Disconnected")

func register_player():
	Save.save_data["Team"] = next_player_team_number
	Save.save_game()
	local_player_id = get_tree().get_network_unique_id()
	player_data = Save.save_data
	players[local_player_id] = player_data
	print(str(local_player_id) + " register player, next_player_team_number: " + str(next_player_team_number))
	rpc_id(1, "send_player_info", local_player_id, player_data)

sync func update_waiting_room():
	get_tree().call_group("WaitingRoom", "refresh_players", players)

sync func update_next_player_team_number(value):
	print("update_next_player_team_number: " + str(value))
	next_player_team_number = value
	
func load_game():
	rpc_id(1, "load_world")
	
sync func start_game():
	var world = preload("res://world/world.tscn").instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("Lobby").queue_free()
	GameManager.start_round()

func remove_player():
	rpc_id(1, "remove_player")

sync func restart():
	players = {}
	player_data = {}
	next_player_team_number = TEAM1
	
	var lobby = preload("res://lobby/lobby.tscn").instance()
	get_tree().get_root().add_child(lobby)
	get_tree().get_root().get_node("World").queue_free()
