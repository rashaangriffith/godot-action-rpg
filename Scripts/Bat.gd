extends KinematicBody2D

const EnemyDeathEffectScene = preload("res://Scenes/EnemyDeathEffect.tscn")
export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback_vector = Vector2.ZERO
var knockback_velocity = 150
var knockback_friction = 300
var state = IDLE

onready var stats = $Stats
onready var detectionZone = $DetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback_vector = knockback_vector.move_toward(Vector2.ZERO, knockback_friction * delta)
	knockback_vector = move_and_slide(knockback_vector)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			if detectionZone.is_target_detected():
				state = CHASE
			
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.set_timer(rand_range(1, 3))
		WANDER:
			if detectionZone.is_target_detected():
				state = CHASE
			elif wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.set_timer(rand_range(1, 3))
				
				
			var direction = global_position.direction_to(wanderController.target_position)
			velocity = velocity.move_toward(direction * MAX_SPEED / 2, ACCELERATION * delta)
			sprite.flip_h = velocity.x < 0
			
			if global_position.distance_to(wanderController.target_position) <= MAX_SPEED / 10:
				state = pick_random_state([IDLE, WANDER])
				wanderController.set_timer(rand_range(1, 3))
			
		CHASE:
			var target = detectionZone.target
			if target != null:
				var direction = global_position.direction_to(target.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				sprite.flip_h = velocity.x < 0
			else:
				state = IDLE
				
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)
	
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	knockback_vector = area.knockback_vector * knockback_velocity
	stats.health -= area.damage
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffectScene.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	enemyDeathEffect.offset = Vector2(0, -12)

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
