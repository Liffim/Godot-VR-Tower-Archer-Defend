extends Control  # Assuming the script is attached to your Control node

func _on_button_pressed() -> void:
	print("Exiting the game...")
	await create_tween().tween_property(CharacterGlobal.fade, "modulate", Color.BLACK, 1).set_ease(Tween.EASE_IN_OUT).finished
	get_tree().quit()  # This will close the game
