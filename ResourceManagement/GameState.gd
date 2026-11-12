extends Node

var has_started: bool = false
var game_ended: bool = false
var enemies_killed: int = 0
var spawn_position: Vector2 = Vector2.ZERO
var opened_gates: Array[String] = []
var is_new_game: bool = false

const SAVE_PATH = "user://save_data.json"

func _ready() -> void:
	load_game() # Try to load a save file the moment the game starts

func start_new_game():
	has_started = true
	game_ended = false
	enemies_killed = 0
	opened_gates.clear()
	is_new_game = true
	save_game() # Save immediately when starting

func end_game():
	game_ended = true
	has_started = false
	enemies_killed = 0
	opened_gates.clear()
	is_new_game = true
	delete_save() # Delete the save file since they beat the game

func add_enemy_defeat():
	enemies_killed += 1

# --- SAVING AND LOADING ---
func save_game():
	var save_dict = {
		"has_started": has_started,
		"spawn_x": spawn_position.x,
		"spawn_y": spawn_position.y,
		"opened_gates": opened_gates
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_dict))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return # No save file found, game is fresh
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data:
		has_started = data.get("has_started", false)
		spawn_position = Vector2(data.get("spawn_x", 0), data.get("spawn_y", 0))
		
		# JSON saves arrays as generic arrays, so we have to convert it back to a String array
		opened_gates.clear()
		for gate in data.get("opened_gates", []):
			opened_gates.append(str(gate))

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
