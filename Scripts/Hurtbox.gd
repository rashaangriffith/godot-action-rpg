extends Area2D

const HitEffectScene = preload("res://Scenes/HitEffect.tscn")
export var hitEffectOffset = Vector2.ZERO
var is_invincible = false setget set_is_invincible
onready var timer = $Timer
onready var collisionShape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func set_is_invincible(value):
	is_invincible = value
	if (is_invincible == true):
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	timer.start(duration)
	self.is_invincible = true

func create_hit_effect():
#	print("hitbox create_hit_effect for: " + PlayerStats.get_player_data(get_parent().player_id, "Player_name"))
	var hitEffect = HitEffectScene.instance()
	#var main = get_tree().current_scene
	#main.add_child(hitEffect)
	get_parent().add_child(hitEffect)
	hitEffect.global_position = global_position
	hitEffect.offset = hitEffectOffset
	start_invincibility(0.8)

func _on_Timer_timeout():
	self.is_invincible = false

func _on_Hurtbox_invincibility_started():
	collisionShape.set_deferred("disabled", true)

func _on_Hurtbox_invincibility_ended():
	collisionShape.disabled = false
