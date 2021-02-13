extends Control

func _ready():
	print("In Lobby")

func _on_JoinButton_pressed():
	print("Joining...")
	Server._connect_to_server()
