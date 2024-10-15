extends Control  # Assuming the script is attached to your Control node

func _on_Button_pressed():
	# Load the new scene (replace with your scene path)
	var new_scene = preload("res://main.tscn")  # Path to your 'main' scene
	var next_scene = new_scene.instance()  # Create an instance of the scene
	get_tree().change_scene_to(next_scene)  # Switch the scene
