extends XROrigin3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if XRHelpers.get_right_controller(self).is_button_pressed("trigger") and not CharacterGlobal.drawing and not CharacterGlobal.arrow and right_hand_behind():
		grab_arrow(true)
	if not XRHelpers.get_right_controller(self).is_button_pressed("trigger") and CharacterGlobal.arrow:
		grab_arrow(false)
	CharacterGlobal.player_position = position
	CharacterGlobal.left_position = $"Left Hand".global_position
	CharacterGlobal.right_position = $"Right Hand".global_position
	CharacterGlobal.rumbler = $"Right Hand/XRToolsRumbler"
	if CharacterGlobal.burning_arrow:
		$"Right Hand/Arrow".start_burning()
	if CharacterGlobal.arrow:
		$"Right Hand/Arrow".visible = true
	else:
		$"Right Hand/Arrow".visible = false

func grab_arrow(boolie):
	CharacterGlobal.arrow = boolie

func right_hand_behind():
	if $"Right Hand".position.z < $XRCamera3D.position.z:
		return false
	return true

func _on_trigger(event: Variant) -> void:
	print_debug("arrow")
	var event_typed = event as XRToolsPointerEvent
	if event_typed.Type == 2:
		CharacterGlobal.arrow = true
