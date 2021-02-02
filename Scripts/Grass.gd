extends Node2D

const GrassEffectScene = preload("res://Scenes/GrassEffect.tscn")

func create_grass_effect():
	var grassEffect = GrassEffectScene.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position
	queue_free()

func _on_Hurtbox_area_entered(area):
	create_grass_effect()
