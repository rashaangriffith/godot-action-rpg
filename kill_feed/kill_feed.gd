extends Control

const ItemScene = preload("res://kill_feed/kill_feed_item.tscn")

onready var list = $List

func _ready():
	GameManager.connect("killed_player", self, "_on_GameManager_killed_player")

func addItem(message):
	var item = ItemScene.instance()
	list.add_child(item)
	item.addMessage(message)

func _on_GameManager_killed_player(killer_id, killed_id):
	var killer_name = PlayerStats.get_player_name(killer_id)
	var killed_name = PlayerStats.get_player_name(killed_id)
	var is_killer_on_my_team = PlayerStats.is_same_team(killer_id, Server.local_player_id)
	var message = ""
	if is_killer_on_my_team:
		message = "[color=blue]" + killer_name + "[/color] xx [color=red]" + killed_name + "[/color]"
	else:
		message = "[color=red]" + killer_name + "[/color] xx [color=blue]" + killed_name + "[/color]"
	addItem(message)
