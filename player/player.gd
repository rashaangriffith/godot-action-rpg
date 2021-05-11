extends KinematicBody2D

signal shoot(shot, location, direction)

enum PLAYER_STATES {
	MOVE,
	ROLL,
	ATTACK
}

enum SUPER_TYPES {
	SPEED_UP
}

const ShotScene = preload("res://Scenes/Shot.tscn")
const PlayerHurtSoundScene = preload("res://Scenes/PlayerHurtSound.tscn")
const white_color_material = preload("res://materials/white_color_shadermaterial.tres")
const red_outline_material = preload("res://materials/red_outline_shadermaterial.tres")

onready var animationPlayer = $AnimationPlayer
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var follow_hud = $FollowHud
onready var camera = $Camera2D
onready var reload_timer = $ReloadTimer
onready var ap_regen_timer = $APRegenTimer
onready var super_charge_timer = $SuperChargeTimer
onready var super_duration_timer = $SuperDurationTimer
onready var sprite = $Sprite
onready var weapon_sprite = $WeaponSprite
onready var death_audio_player = $DeathAudioPlayer

export var MAX_SPEED = 80
export var ACCELERATION = 500
export var FRICTION = 500
export var ROLL_SPEED = 125
export var MAX_HEALTH = 5
export var MAX_AMMO = 10
export var MAX_AP = 4
export var MAX_SUPER = 100
export var SUPER_CHARGE_RATE = 20

var player_id = 0
var velocity = Vector2.ZERO
var state = PLAYER_STATES.MOVE
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var input_vector = Vector2.ZERO
var look_vector = Vector2.ZERO
var knockback_vector = Vector2.ZERO
var knockback_velocity = 150
var knockback_friction = 300
var spawn_position = Vector2.ZERO
var remaining_ammo = MAX_AMMO
var is_reloading = false
var ability_1 = {
	"cost": 2
}
var ability_2 = {
	"cost": 3
}
var remaining_ap = MAX_AP
var super = {
	"type": SUPER_TYPES.SPEED_UP,
	"duration": 5
}
var super_meter_count = 0
var last_damaged_id = 0
var last_damager_id = 0
var kills = 0
var deaths = 0

func _ready():
	randomize() # get a different random seed on each play
	animationTree.active = true
	swordHitbox.player_id = player_id
	swordHitbox.knockback_vector = look_vector
	PlayerStats.set_player_max_health(player_id, MAX_HEALTH)
	stats.connect("no_health", self, "_on_PlayerStats_no_health")
	#name_label.set_as_toplevel(true)
	set_name_label()
	GameManager.connect("round_started", self, "_on_GameManager_start_round")
	GameManager.connect("round_game_started", self, "_on_GameManager_start_round_game")
	GameManager.connect("last_damaged", self, "_on_GameManager_last_damaged")
	set_remaining_ammo_count(remaining_ammo)
	set_remaining_ap_count(remaining_ap)
	follow_hud.player_id = player_id
	
	print("local_player_id: " + str(Server.local_player_id) + " | player_id: " + str(player_id))
	
	if not PlayerStats.is_same_team(Server.local_player_id, player_id):
		sprite.material = red_outline_material

func _physics_process(delta):
	if is_network_master():
		camera.current = true
		get_input()
		
		var data = {
			"transform": global_transform,
			"state": state,
			"input": input_vector,
			"look": look_vector
		}
		rpc_unreliable_id(1, "update_player", data)
		
	match state:
		PLAYER_STATES.MOVE:
			move_state(delta)
		PLAYER_STATES.ATTACK:
			attack_state(delta)
		PLAYER_STATES.ROLL:
			roll_state(delta)
	
	# handle knockback
	if knockback_vector != Vector2.ZERO:
		knockback_vector = knockback_vector.move_toward(Vector2.ZERO, knockback_friction * delta)
		knockback_vector = move_and_slide(knockback_vector)

remote func update_remote_player(data):
	if not is_network_master():
		global_transform = data.transform
		state = data.state
		input_vector = data.input
		look_vector = data.look
		weapon_sprite.global_rotation = atan2(look_vector.y, look_vector.x)
		#print("state (" + Server.players[int(name)]["Player_name"] + "): " + PLAYER_STATES.keys()[state])
		
func set_name_label():
	var player_name = PlayerStats.get_player_name(player_id)
	follow_hud.set_name_label(player_name, player_id)
	
func get_input():
#	get move vector
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
#	get look vector
	look_vector = get_global_mouse_position() - global_position
	look_vector = look_vector.normalized()
	weapon_sprite.global_rotation = atan2(look_vector.y, look_vector.x)
	
	if Input.is_action_just_pressed("primary_attack"):
#		print("input attack: shoot")
		#emit_signal("shoot", ShotScene, position, roll_vector)
		# won't need this strange world_objects reference once input_manager singleton is implemented
		if is_reloading:
			return
			
		if remaining_ammo > 0:
			var world_objects = get_parent().get_parent()
			world_objects._on_Player_shoot(ShotScene, position, look_vector, player_id)
			set_remaining_ammo_count(remaining_ammo - 1)
		else:
			reload()
	elif Input.is_action_just_pressed("ability_1"):
#		print(PlayerStats.get_player_data(player_id, "Player_name") + " has attacked")
		if remaining_ap >= ability_1.cost:
			state = PLAYER_STATES.ATTACK
			set_remaining_ap_count(remaining_ap - ability_1.cost)
			if ap_regen_timer.is_stopped():
				ap_regen_timer.start()
	elif Input.is_action_just_pressed("ability_2"):
#		print("input ability_2: roll")
		if remaining_ap >= ability_2.cost:
			state = PLAYER_STATES.ROLL
			hurtbox.start_invincibility()
			set_remaining_ap_count(remaining_ap - ability_2.cost)
			if ap_regen_timer.is_stopped():
				ap_regen_timer.start()
	elif Input.is_action_just_pressed("reload"):
		if not is_reloading and remaining_ammo < MAX_AMMO:
			reload()
	elif Input.is_action_just_pressed("super"):
		print("super meter count: " + str(super_meter_count) + " | max: " + str(MAX_SUPER))
		if super_meter_count == MAX_SUPER:
			activate_super()
	
func move_state(delta):
	roll_vector = input_vector
	swordHitbox.knockback_vector = look_vector
	
	animationTree.set("parameters/Idle/blend_position", look_vector)
	animationTree.set("parameters/Run/blend_position", look_vector)
	animationTree.set("parameters/Attack/blend_position", look_vector)
	animationTree.set("parameters/Roll/blend_position", look_vector)
	
	if input_vector != Vector2.ZERO:	
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
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

func reset_player():
	position = spawn_position
	set_remaining_ammo_count(MAX_AMMO)
	set_remaining_ap_count(MAX_AP)
#	set_super_meter_count(0)
	PlayerStats.reset_player(player_id)
#	super_charge_timer.stop()
	
func die():
	reset_player()
	kills += 1
	PlayerStats.set_deaths_count(kills, player_id)
	death_audio_player.play()

func start_round():
	reset_player()
	kills = 0
	deaths = 0

func set_remaining_ammo_count(value):
	remaining_ammo = clamp(value, 0, MAX_AMMO)
	PlayerStats.set_ammo_count(remaining_ammo, MAX_AMMO, player_id)

func set_remaining_ap_count(value):
	remaining_ap = clamp(value, 0, MAX_AP)
	if value >= MAX_AP:
		ap_regen_timer.stop()
	PlayerStats.set_ap_count(remaining_ap, player_id)
	
	if ability_1.cost <= remaining_ap:
		PlayerStats.set_ability_1_disabled(false, player_id)
	else:
		PlayerStats.set_ability_1_disabled(true, player_id)
	
	if ability_2.cost <= remaining_ap:
		PlayerStats.set_ability_2_disabled(false, player_id)
	else:
		PlayerStats.set_ability_2_disabled(true, player_id)

func set_super_meter_count(value):
	super_meter_count = clamp(value, 0, MAX_SUPER)
	print(PlayerStats.get_player_name(player_id) + "'s super meter count is " + str(super_meter_count))
	if value >= MAX_SUPER:
		print(PlayerStats.get_player_name(player_id) + "'s super is ready to use")
		super_charge_timer.stop()
	PlayerStats.set_super_meter_count(super_meter_count, player_id)

func reload():
	print(PlayerStats.get_player_name(player_id) + " is reloading primary weapon...")
	reload_timer.start()
	is_reloading = true

func activate_super():
	print(PlayerStats.get_player_name(player_id) + " activated super")
	super_charge_timer.stop()
	set_super_meter_count(0)
	
	if super.type == SUPER_TYPES.SPEED_UP:
		MAX_SPEED *= 2
		blinkAnimationPlayer.play("Start")
	
	super_duration_timer.wait_time = super.duration
	super_duration_timer.start()

func _on_Hurtbox_area_entered(area):
	print("-----------player onHurtbox entered")
#	print("hitbox player_id: " + PlayerStats.get_player_data(area.player_id, "Player_name"))
#	print("hurtbox player_id: " + PlayerStats.get_player_data(player_id, "Player_name"))
	
	if not PlayerStats.is_same_team(area.player_id, player_id):
#		print("match found, damage to: " + PlayerStats.get_player_data(player_id, "Player_name"))
		#stats.health -= area.damage
		PlayerStats.player_take_damage(player_id, 1, area.player_id, kills)
#		set_name_label(Color(1, 0, 0))
		hurtbox.create_hit_effect()
		var playerHurtSound = PlayerHurtSoundScene.instance()
		get_parent().add_child(playerHurtSound)
		last_damager_id = area.player_id
		GameManager.set_last_damaged(area.player_id, player_id)
		
		if area.is_shot:
			area.get_parent().handle_collision()
		
		knockback_vector = area.knockback_vector * knockback_velocity

func _on_Hurtbox_invincibility_started():
	if not PlayerStats.is_same_team(Server.local_player_id, player_id):
		sprite.material = white_color_material
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	if not PlayerStats.is_same_team(Server.local_player_id, player_id):
		sprite.material = red_outline_material
	blinkAnimationPlayer.play("Stop")

func _on_PlayerStats_no_health(id):
	if player_id == id:
		die()
		GameManager.player_killed(last_damager_id, player_id)
	elif last_damaged_id == id:
		GameManager.killed_player(player_id, last_damaged_id)
		
func _on_GameManager_start_round(current_round):
	start_round()
		
func _on_GameManager_start_round_game():
	super_charge_timer.start()

func _on_ReloadTimer_timeout():
	print(PlayerStats.get_player_name(player_id) + "'s primary weapon is reloaded")
	set_remaining_ammo_count(MAX_AMMO)
	is_reloading = false

func _on_APRegenTimer_timeout():
	set_remaining_ap_count(remaining_ap + 1)

func _on_SuperChargeTimer_timeout():
	set_super_meter_count(super_meter_count + SUPER_CHARGE_RATE)

func _on_SuperDurationTimer_timeout():
	print(PlayerStats.get_player_name(player_id) + "'s super ended")
	if super.type == SUPER_TYPES.SPEED_UP:
		MAX_SPEED /= 2
		blinkAnimationPlayer.play("Stop")
	
	super_charge_timer.start()

func _on_GameManager_last_damaged(player, damaged):
	if player == player_id:
		last_damaged_id = damaged
