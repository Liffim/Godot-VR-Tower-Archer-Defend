extends Node3D  # Assuming the tent is a Node3D; change this to the actual type if needed

func load_scene():
	var scene_to_load = load("res://main.tscn")  # Load the scene manually
	if scene_to_load != null:
		print("Loading scene: ", scene_to_load)
		get_tree().change_scene_to(scene_to_load)
	else:
		print("No scene assigned to load!")
