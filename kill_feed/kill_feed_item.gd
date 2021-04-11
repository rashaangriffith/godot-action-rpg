extends Control

onready var label = $Label
onready var timer = $Timer

func addMessage(message):
	label.bbcode_text = message
	timer.start()

func _on_Timer_timeout():
	queue_free()
