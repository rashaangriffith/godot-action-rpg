extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty
onready var teamLabel = $TeamLabel

func set_hearts(value):
	hearts = clamp(value, 0 , max_hearts)
	if (heartUIFull != null):
		heartUIFull.rect_size.x = hearts * 15
	
	# this needs to be moved somewhere else
	teamLabel.text = "Team: " + PlayerStats.get_player_data(Server.local_player_id, "Team")
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	hearts = min(hearts, max_hearts)
	if (heartUIEmpty != null):
		heartUIEmpty.rect_size.x = max_hearts * 15

func _ready():
#	self.max_hearts = PlayerStats.get_player_data(Server.local_player_id, "MaxHealth")
#	self.hearts = PlayerStats.get_player_data(Server.local_player_id, "Health")
#	print("HealthUI for: " + str(Server.local_player_id))
#	print("local max health: " + str(PlayerStats.get_player_data(Server.local_player_id, "MaxHealth")))
#	print("local health: " + str(PlayerStats.get_player_data(Server.local_player_id, "Health")))
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
