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

func handle_collision():
	queue_free()

func _on_Hitbox_body_entered(body):
#	COLLIDE WITH THE WORLD
	handle_collision()
