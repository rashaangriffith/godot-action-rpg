extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty
onready var nameLabel = $NameLabel
onready var ammo_count = $AmmoCount
onready var ability_points_full = $AbilityPointsFull
onready var ability_1 = $Ability1
onready var ability_2 = $Ability2
onready var super_meter = $SuperMeter

func _ready():
#	self.max_hearts = PlayerStats.get_player_data(Server.local_player_id, "MaxHealth")
#	self.hearts = PlayerStats.get_player_data(Server.local_player_id, "Health")
#	print("HealthUI for: " + str(Server.local_player_id))
#	print("local max health: " + str(PlayerStats.get_player_data(Server.local_player_id, "MaxHealth")))
#	print("local health: " + str(PlayerStats.get_player_data(Server.local_player_id, "Health")))
	nameLabel.text = PlayerStats.get_player_data(Server.local_player_id, "Player_name")
	PlayerStats.connect("health_changed", self, "_on_PlayerStats_health_changed")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	PlayerStats.connect("ammo_count_changed", self, "_on_PlayerStats_ammo_count_changed")
	PlayerStats.connect("ap_count_changed", self, "_on_PlayerStats_ap_count_changed")
	PlayerStats.connect("ability_1_disabled", self, "_on_PlayerStats_ability_1_disabled")
	PlayerStats.connect("ability_2_disabled", self, "_on_PlayerStats_ability_2_disabled")
	PlayerStats.connect("super_meter_count_changed", self, "_on_PlayerStats_super_meter_count_changed")

func set_hearts(value):
	hearts = clamp(value, 0 , max_hearts)
	if (heartUIFull != null):
		heartUIFull.rect_size.x = hearts * 15
	
	# this needs to be moved somewhere else
#	nameLabel.text = PlayerStats.get_player_data(Server.local_player_id, "Player_name")
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	hearts = min(hearts, max_hearts)
	if (heartUIEmpty != null):
		heartUIEmpty.rect_size.x = max_hearts * 15

func _on_PlayerStats_health_changed(value, player_id):
	if player_id == Server.local_player_id:
		set_hearts(value)

func _on_PlayerStats_ammo_count_changed(remaining, maximum):
	ammo_count.text = str(remaining) + " / " + str(maximum)

func _on_PlayerStats_ap_count_changed(value):
	ability_points_full.rect_size.x = value * 16

func _on_PlayerStats_ability_1_disabled(value):
#	print("hud on ability 1 disabled, value: " + str(value) + " | node or null: " + str(get_node_or_null(ability_1) == null))
	var is_ability_1_added = not get_node_or_null(ability_1.get_path()) == null
	if value and is_ability_1_added:
		remove_child(ability_1)
	elif not value and not is_ability_1_added:
		add_child(ability_1)

func _on_PlayerStats_ability_2_disabled(value):
	var is_ability_2_added = not get_node_or_null(ability_2.get_path()) == null
	if value and is_ability_2_added:
		remove_child(ability_2)
	elif not value and not is_ability_2_added:
		add_child(ability_2)

func _on_PlayerStats_super_meter_count_changed(value):
	super_meter.value = value
