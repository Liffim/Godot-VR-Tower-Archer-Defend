extends Node3D  # Change this to MeshInstance3D or whatever the actual type of the tent is

# Exported variable to allow scene loading
export (PackedScene) var scene_to_load

func load_scene():
	if scene_to_load != null:
		print("Loading scene: ", scene_to_load)
		get_tree().change_scene_to(scene_to_load)
	else:
		print("No scene assigned to load!")
