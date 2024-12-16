extends XROrigin3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	create_tween().tween_property($XRCamera3D/Sprite3D, "modulate", Color.TRANSPARENT, 3).set_ease(Tween.EASE_IN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"Right Hand/MovementTurn".turn_mode = CharacterGlobal.turn_mode
	#$"Right Hand/MovementTurn"._turn_step = CharacterGlobal.turn_radius
	CharacterGlobal.fade = $XRCamera3D/Sprite3D
	CharacterGlobal.holster_position = $Node3D/Holster.global_position
	CharacterGlobal.holster_rotation = $XRCamera3D.rotation.y
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
		# this is bug
	if not CharacterGlobal.burning_arrow:
		$"Right Hand/Arrow".stop_burning()
	if CharacterGlobal.arrow:
		$"Right Hand/Arrow".visible = true
	else:
		$"Right Hand/Arrow".visible = false

func grab_arrow(boolie):
	CharacterGlobal.arrow = boolie
	CharacterGlobal.burning_arrow = false

func right_hand_behind():
	if $XRCamera3D/Node3D2.position.z < 0:
		return false
	return true

func _on_trigger(event: Variant) -> void:
	print_debug("arrow")
	var event_typed = event as XRToolsPointerEvent
	if event_typed.Type == 2:
		CharacterGlobal.arrow = true
