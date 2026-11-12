extends Node

@onready var dialogue_ui = get_parent().get_node("DialogueUi")
var current_node_data: Dictionary = {}
var is_cutscene_active: bool = false
var pending_fail: bool = false

func _ready():
	add_to_group("dialogue_manager") 
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	dialogue_ui.choice_made.connect(_on_choice_made)
	dialogue_ui.text_submitted.connect(_on_text_submitted)
	dialogue_ui.visible = false

func start_dialogue(start_node_id: String):
	is_cutscene_active = true
	pending_fail = false
	get_tree().call_group("interactables", "set_active", false) 
	get_tree().call_group("nav_buttons", "set_active", false)
	
	_load_node(start_node_id)

func _load_node(node_id: String):
	current_node_data = DialogueData.get_dialogue(node_id)
	
	if current_node_data.is_empty():
		_end_dialogue()
		return
	
	if current_node_data.has("action"):
		_execute_action(current_node_data["action"])
		
	dialogue_ui.start_dialogue(current_node_data)

func _on_dialogue_finished():
	if current_node_data.has("dynamic_next"):
		var next_node = current_node_data["dynamic_next"].call()
		if next_node == "": 
			_end_dialogue()
		else: 
			_load_node(next_node)
	else:
		var next_node = current_node_data.get("next", "")
		if next_node == "":
			_end_dialogue()
		else:
			_load_node(next_node)

func _on_choice_made(next_node_id: String):
	_load_node(next_node_id)

func _on_text_submitted(answer: String):
	var valid_answers = current_node_data.get("valid_answers", [])
	if answer in valid_answers:
		_load_node(current_node_data["next_on_success"])
	else:
		_load_node(current_node_data["next_on_fail"])

func _end_dialogue():
	is_cutscene_active = false
	dialogue_ui.hide_ui() 
	get_tree().call_group("interactables", "set_active", true)
	get_tree().call_group("nav_buttons", "set_active", true)
	
	if pending_fail:
		get_tree().change_scene_to_file("res://ui/fail.tscn")

func _execute_action(action_string: String):
	var parts = action_string.split(":")
	if parts[0] == "add_key":
		GameState.add_key(parts[1])
	elif parts[0] == "trigger_fail":
		pending_fail = true
