extends Control

onready var player_name = $CenterContainer/VBoxContainer/GridContainer/NameTextBox
#onready var team = $CenterContainer/VBoxContainer/GridContainer/TeamTextBox
#onready var selected_ip = $CenterContainer/VBoxContainer/GridContainer/IPTextBox
#onready var selected_port = $CenterContainer/VBoxContainer/GridContainer/PortTextBox
onready var waiting_room = $WaitingRoom
onready var ready_button = $WaitingRoom/CenterContainer/VBoxContainer/ReadyButton
onready var status = $CenterContainer/VBoxContainer/Status

func _ready():
	player_name.text = Save.save_data["Player_name"]
	Server.connect("connection_status_changed", self, "_on_Server_connection_status_changed")
#	selected_ip.text = Server.DEFAULT_IP
#	selected_port.text = str(Server.DEFAULT_PORT)

func _on_JoinButton_pressed():
	print("Joining...")
#	Server.selected_ip = selected_ip.text
#	Server.selected_port = int(selected_port.text)
#	Server.selected_ip = Server.DEFAULT_IP
#	Server.selected_port = Server.DEFAULT_PORT
#	Server._connect_to_server()
	Server.register_player()
	show_waiting_room()

func _on_NameTextBox_text_changed(new_text):
	Save.save_data["Player_name"] = player_name.text
	Save.save_game()

#func _on_TeamTextBox_text_changed(new_text):
#	Save.save_data["Team"] = team.text
#	Save.save_game()

func show_waiting_room():
	waiting_room.popup_centered()

func _on_ReadyButton_pressed():
	Server.load_game()
	ready_button.disabled = true

func _on_Server_connection_status_changed(message):
	status.text = message
