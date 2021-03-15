extends YSort

const ShotScene = preload("res://Scenes/Shot.tscn")

func _on_Player_shoot(shotScene, location, direction, player_id):
	var shot = shotScene.instance()
	shot.speed = 200
	shot.position = location
	shot.velocity = direction
	shot.player_id = player_id
	add_child(shot)
	
	var data = {"location": location, "direction": direction, "player_id": player_id}
	rpc_unreliable_id(1, "spawn_shot", data)

remote func remote_spawn_shot(data):
	if not Server.local_player_id == data.player_id:
		var shot = ShotScene.instance()
		shot.speed = 200
		shot.position = data.location
		shot.velocity = data.direction
		shot.player_id = data.player_id
		add_child(shot)
