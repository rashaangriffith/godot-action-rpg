extends Area2D

var speed: float = 200
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta):
	position += velocity * speed * delta

func _on_Hurtbox_area_entered(area):
	queue_free()
