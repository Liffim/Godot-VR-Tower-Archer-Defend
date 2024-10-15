extends XRController3D

func _process(delta):
	# Check if the A button is pressed on this controller
	if get_button_pressed(XRController.):
		print("A button pressed")

	# Check if the trigger is pressed
	if get_trigger_value() > 0.1:  # Value ranges from 0 to 1
		print("Trigger pressed")
