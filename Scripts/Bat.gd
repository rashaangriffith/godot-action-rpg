extends KinematicBody2D

const EnemyDeathEffectScene = preload("res://Scenes/EnemyDeathEffect.tscn")

var knockback_vector = Vector2.ZERO
var knockback_speed = 150
var knockback_friction = 300

onready var stats = $Stats

func _ready():
	print(stats.max_health)
	print(stats.health)

func _physics_process(delta):
	knockback_vector = knockback_vector.move_toward(Vector2.ZERO, knockback_friction * delta)
	knockback_vector = move_and_slide(knockback_vector)

func _on_Hurtbox_area_entered(area):
	knockback_vector = area.knockback_vector * knockback_speed
	stats.health -= area.damage


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffectScene.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
