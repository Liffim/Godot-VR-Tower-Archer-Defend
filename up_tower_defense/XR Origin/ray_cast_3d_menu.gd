# Script attached to RayCast3D
extends RayCast3D

func _process(delta):
	if is_colliding():
		var collider = get_collider()
		if collider.name == "Tent":
			print("Tent clicked")
			# You can emit a signal or trigger any function here.
			on_tent_clicked()

func on_tent_clicked():
	# Function that runs when tent is clicked
	print("Tent interaction triggered!")
	# Add more functionality like opening a UI, etc.
