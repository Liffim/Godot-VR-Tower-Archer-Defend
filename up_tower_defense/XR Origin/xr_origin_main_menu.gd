extends XROrigin3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	CharacterGlobal.fade = $XRCamera3D/Sprite3D
	$"Right Hand/MovementTurn".turn_mode = CharacterGlobal.turn_mode
	$"Right Hand/MovementTurn".step_turn_angle = CharacterGlobal.turn_radius
