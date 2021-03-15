extends Node

const SAVE_GAME = "user://save-game.json"

var save_data = {}

func _ready():
	save_data = get_data()

func get_data():
	var file = File.new()
	
	if not file.file_exists(SAVE_GAME):
		save_data = {"Player_name": "Unnamed"}
		save_game()
	file.open(SAVE_GAME, File.READ)
	var data = parse_json(file.get_as_text())
	save_data = data
	file.close()
	return(data)
	
func save_game():
	var save_game = File.new()
	save_game.open(SAVE_GAME, File.WRITE)
	save_game.store_line(to_json(save_data))
