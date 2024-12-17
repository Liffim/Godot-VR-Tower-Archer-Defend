extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	await create_tween().tween_property(CharacterGlobal.fade, "modulate", Color.BLACK, 1).set_ease(Tween.EASE_IN_OUT).finished
	get_tree().change_scene_to_file("res://MainMenu.tscn")
