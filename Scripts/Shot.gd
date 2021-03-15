extends Area2D

var speed: float = 200
var velocity: Vector2 = Vector2.ZERO
var player_id = 0
onready var hitbox = $Hitbox

func _ready():
	hitbox.player_id = player_id
	hitbox.is_shot = true

func _physics_process(delta):
	position += velocity * speed * delta

func _on_Hurtbox_area_entered(area):
	pass
	#print("-----------shot onHurtbox entered")
	#print("area player_id: " + PlayerStats.get_player_data(area.player_id, "Player_name"))
	#print("shot player_id: " + PlayerStats.get_player_data(player_id, "Player_name"))
	#if not PlayerStats.is_same_team(area.player_id, player_id):
	#	queue_free()

func handle_collision():
	queue_free()
