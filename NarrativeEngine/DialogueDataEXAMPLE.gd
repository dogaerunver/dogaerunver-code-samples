class_name DialogueData

static func get_dialogue(node_id: String) -> Dictionary:
	var data = {
		"intro": {
			"name": "Narrator",
			"sprite": "res://assets/sprites/spr/emp.png",
			"text": "A great morning under the blazing sun...",
			"next": "sparkintro_1"
		},
		"sparkintro_1": {
			"name": "Spark",
			"sprite": "res://assets/sprites/spr/spark/behind.png",
			"text": "He had always been a rowdy man.",
			"next": "ayres_door1"
		},
		"ayres_door1": {
			"name": "Ayres",
			"sprite": "res://assets/sprites/spr/Ayres/ay2.png",
			"text": "'What is it?'",
			"choices": [
				{"text": "'I want to be at the tower t-tonight.'", "dynamic_next": func(): return "ayres_repeat" if GameState.has_key("doorc3") else "ayres_door2"},
				{"text": "'I was just wondered where he was.'", "next": "ayres_door3"}
			]
		},
		"ayres_repeat": {
			"name": "Ayres",
			"sprite": "res://assets/sprites/spr/Ayres/ayfold1.png",
			"text": "I know. You can be.",
			"next": ""
		},
		"ayres_door2": {
			"name": "Ayres",
			"sprite": "res://assets/sprites/spr/Ayres/ayfold2.png",
			"text": "...I'll bring you to the top tonight if you tell me the password.'",
			"input_prompt": true, 
			"valid_answers": ["APOSTHEOSIS", "apostheosis"], 
			"next_on_success": "doorc1",
			"next_on_fail": "doorw"
		}
	}
	return data.get(node_id, {})
