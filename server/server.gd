extends Node

const DEFAULT_IP: String = "127.0.0.1"
const DEFAULT_PORT: int = 9000

var network = NetworkedMultiplayerENet.new()
var selected_ip: String = ""
var selected_port: int = 0

var local_player_id: int = 0
sync var players = {}
sync var player_data = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _connect_to_server():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	network.create_client(selected_ip, selected_port)
	get_tree().set_network_peer(network)

func _player_connected(id):
	print("Player: " + str(id) + " Connected")
	
func _player_disconnected(id):
	print("Player: " + str(id) + " Disconnected")
	
func _connected_ok():
	print("Successfully Connected")
	register_player()
	rpc_id(1, "send_player_info", local_player_id, player_data)
	
func _connected_fail():
	print("Connection Failed")
	
func _server_disconnected():
	print("Server Disconnected")

func register_player():
	local_player_id = get_tree().get_network_unique_id()
	player_data = Save.save_data
	players[local_player_id] = player_data

sync func update_waiting_room():
	get_tree().call_group("WaitingRoom", "refresh_players", players)
	
func load_game():
	rpc_id(1, "load_world")
	
sync func start_game():
	var world = preload("res://world/world.tscn").instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("Lobby").queue_free()
	GameManager.start_round()
