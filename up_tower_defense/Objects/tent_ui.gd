extends Control  # Assuming the script is attached to your Control node

func _on_button_pressed() -> void:
	print("Exiting the game...")
	get_tree().quit()  # This will close the game
