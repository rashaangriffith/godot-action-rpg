extends Area2D

onready var sprite = $Sprite
onready var hitbox = $Hitbox

var speed: float = 300
var velocity: Vector2 = Vector2.ZERO
var player_id = 0

func _ready():
	hitbox.player_id = player_id
	hitbox.is_shot = true
	var is_same_team = PlayerStats.is_same_team(player_id, Server.local_player_id)
	if is_same_team:
		sprite.self_modulate = PlayerStats.MY_TEAM_COLOR
	else:
		sprite.self_modulate = PlayerStats.OTHER_TEAM_COLOR

func _physics_process(delta):
	position += velocity * speed * delta

func handle_collision():
	queue_free()

func _on_Hitbox_body_entered(body):
#	COLLIDE WITH THE WORLD
	handle_collision()
