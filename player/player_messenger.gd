extends Control

onready var label = $Label
onready var timer = $Timer

func _ready():
	GameManager.connect("player_killed", self, "_on_GameManager_player_killed")
	GameManager.connect("killed_player", self, "_on_GameManager_killed_player")

func _on_GameManager_player_killed(killer_id, killed_id):
	if killed_id == Server.local_player_id:
		timer.wait_time = 3
		timer.start()
		var killer_name = PlayerStats.get_player_name(killer_id)
		label.bbcode_text = "[center]Eliminated by [color=red]" + killer_name + "[/color][/center]"

func _on_GameManager_killed_player(killer_id, killed_id):
	if killer_id == Server.local_player_id:
		timer.wait_time = 3
		timer.start()
		var killed_name = PlayerStats.get_player_name(killed_id)
		label.bbcode_text = "[center]Eliminated [color=red]" + killed_name + "[/color][/center]"

func _on_Timer_timeout():
	label.bbcode_text = ""
