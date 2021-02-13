extends KinematicBody2D

signal shoot(shot, location, direction)

const ShotScene = preload("res://Scenes/Shot.tscn")
const PlayerHurtSoundScene = preload("res://Scenes/PlayerHurtSound.tscn")

export var MAX_SPEED = 80
export var ACCELERATION = 500
export var FRICTION = 500
export var ROLL_SPEED = 125

enum {
	MOVE,
	ROLL,
	ATTACK
}

var velocity = Vector2.ZERO
var state = MOVE
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var input_vector = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox

func _ready():
	randomize() # get a different random seed on each play
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	stats.connect("no_health", self, "queue_free")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		ROLL:
			roll_state(delta)
	
func move_state(delta):
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if (input_vector != Vector2.ZERO):
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animationState.travel("Idle")
		
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	elif Input.is_action_just_pressed("attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("shoot"):
		emit_signal("shoot", ShotScene, position, roll_vector)

func roll_state(delta):
	animationState.travel("Roll")
	velocity = roll_vector * ROLL_SPEED
	move()

func attack_state(delta):
	animationState.travel("Attack")
	velocity = Vector2.ZERO
	
func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	state = MOVE
	velocity = Vector2.ZERO
	
func attack_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSoundScene.instance()
	get_tree().current_scene.add_child(playerHurtSound)

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
