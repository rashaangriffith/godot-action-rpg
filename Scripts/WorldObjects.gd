extends YSort

func _on_Player_shoot(shotScene, location, direction):
	var shot = shotScene.instance()
	shot.speed = 200
	shot.position = location
	shot.velocity = direction
	add_child(shot)
