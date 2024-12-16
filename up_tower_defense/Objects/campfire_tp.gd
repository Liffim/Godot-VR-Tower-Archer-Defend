extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
		# Load the new scene (replace with your scene path)
	print("Button pressed, attempting to change scene.")
	print("Button pressed, switching scenes...")
	# Directly change the scene to your main scene
	await create_tween().tween_property(CharacterGlobal.fade, "modulate", Color.BLACK, 1).set_ease(Tween.EASE_IN_OUT).finished
	get_tree().change_scene_to_file("res://MainPlayMap/MainPlayMap.tscn")
