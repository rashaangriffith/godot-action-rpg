extends Node2D

func create_grass_effect():
	var GrassEffectScene = load("res://Scenes/GrassEffect.tscn")
	var grassEffect = GrassEffectScene.instance()
	var main = get_tree().current_scene
	main.add_child(grassEffect)
	grassEffect.global_position = global_position
	queue_free()

func _on_Hurtbox_area_entered(area):
	create_grass_effect()
