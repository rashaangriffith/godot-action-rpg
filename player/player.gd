extends KinematicBody2D

signal shoot(shot, location, direction)

const ShotScene = preload("res://Scenes/Shot.tscn")
const PlayerHurtSoundScene = preload("res://Scenes/PlayerHurtSound.tscn")

export var MAX_SPEED = 80
export var ACCELERATION = 500
export var FRICTION = 500
export var ROLL_SPEED = 125
export var MAX_HEALTH = 5

enum PLAYER_STATES {
	MOVE,
	ROLL,
	ATTACK
}

var player_id = 0
var velocity = Vector2.ZERO
var state = PLAYER_STATES.MOVE
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var input_vector = Vector2.ZERO
var spawn_position = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var name_label = $NameLabel
onready var camera = $Camera2D

func _ready():
	randomize() # get a different random seed on each play
	animationTree.active = true
	swordHitbox.player_id = player_id
	swordHitbox.knockback_vector = roll_vector
	PlayerStats.set_player_max_health(player_id, MAX_HEALTH)
	stats.connect("no_health", self, "_on_PlayerStats_no_health")
	#name_label.set_as_toplevel(true)
	set_name_label()
	GameManager.connect("round_started", self, "_on_GameManager_start_round")

func _physics_process(delta):
	if is_network_master():
		camera.current = true
		get_input()
		
		var data = {
			"transform": global_transform,
			"state": state,
			"input": input_vector
		}
		rpc_unreliable_id(1, "update_player", data)
		
	match state:
		PLAYER_STATES.MOVE:
			move_state(delta)
		PLAYER_STATES.ATTACK:
			attack_state(delta)
		PLAYER_STATES.ROLL:
			roll_state(delta)

remote func update_remote_player(data):
	if not is_network_master():
		global_transform = data.transform
		state = data.state
		input_vector = data.input
		#print("state (" + Server.players[int(name)]["Player_name"] + "): " + PLAYER_STATES.keys()[state])
		
func set_name_label():
	var player_name = PlayerStats.get_player_data(player_id, "Player_name")
	name_label.text = player_name
#	var team = PlayerStats.get_player_data(player_id, "Team")
#	var health = PlayerStats.get_player_data(player_id, "Health")
#	name_label.text = player_name + " (Team: " + team + ") (Health: " + str(health) + ")"
	
func get_input():
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if Input.is_action_just_pressed("roll"):
		print("input roll")
		state = PLAYER_STATES.ROLL
	elif Input.is_action_just_pressed("attack"):
		print(PlayerStats.get_player_data(player_id, "Player_name") + " has attacked")
		state = PLAYER_STATES.ATTACK
	elif Input.is_action_just_pressed("shoot"):
		print("input shoot")
		#emit_signal("shoot", ShotScene, position, roll_vector)
		var world_objects = get_parent().get_parent()
		world_objects._on_Player_shoot(ShotScene, position, roll_vector, player_id)
	
func move_state(delta):
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
	state = PLAYER_STATES.MOVE
	velocity = Vector2.ZERO
	
func attack_animation_finished():
	state = PLAYER_STATES.MOVE
	
func die():
	position = spawn_position
	PlayerStats.reset_player(player_id)

func start_round():
	position = spawn_position
	PlayerStats.reset_player(player_id)

func _on_Hurtbox_area_entered(area):
#	print("-----------player onHurtbox entered")
#	print("hitbox player_id: " + PlayerStats.get_player_data(area.player_id, "Player_name"))
#	print("hurtbox player_id: " + PlayerStats.get_player_data(player_id, "Player_name"))
	
	if not PlayerStats.is_same_team(area.player_id, player_id):
#		print("match found, damage to: " + PlayerStats.get_player_data(player_id, "Player_name"))
		#stats.health -= area.damage
		PlayerStats.player_take_damage(player_id, 1)
		set_name_label()
		hurtbox.create_hit_effect()
		var playerHurtSound = PlayerHurtSoundScene.instance()
		get_parent().add_child(playerHurtSound)
		
		if area.is_shot:
			area.get_parent().handle_collision()

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

func _on_PlayerStats_no_health(id):
	if player_id == id:
		die()
		
func _on_GameManager_start_round(current_round):
	start_round()
