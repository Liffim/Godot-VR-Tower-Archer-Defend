extends Node3D

@onready var label : Label3D = $Text

func go_up():
	create_tween().tween_property(label, "modulate", Color.TRANSPARENT, 3).set_ease(Tween.EASE_IN)
	create_tween().tween_property(label, "outline_modulate", Color.TRANSPARENT, 3).set_ease(Tween.EASE_IN)
	create_tween().tween_property(self, "position", position + Vector3(0, 0.6, 0), 2)

func _process(delta: float) -> void:
	look_at(CharacterGlobal.player_position)

func set_text(text):
	label.text = str(text)
	
func set_size(size):
	label.font_size *= size
	
func set_color(color):
	if(color == "yellow"):
		label.modulate = Color.YELLOW
	if(color == "blue"):
		label.modulate = Color.BLUE
	if(color == "white"):
		label.modulate = Color.WHITE
	if(color == "black"):
		label.modulate = Color.BLACK
		label.outline_modulate = Color.WHITE
	if(color == "red"):
		label.modulate = Color.RED
