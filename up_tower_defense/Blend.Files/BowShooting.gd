extends Node3D  # Attach this script to the `bow_low_w_anims` node

# Preload the arrow scene and ensure it is treated as a PackedScene
var ArrowScene = load("res://Objects/arrow.tscn") as PackedScene

# Variables for arrow spawning and shooting
var arrow_instance: RigidBody3D = null
var draw_strength: float = 0.0
var max_draw_strength: float = 30.0  # Adjust as needed for force
var is_drawing: bool = false
var left_hand_grabbed: bool = false
var right_hand_grabbed: bool = false

# Nodes for arrow attachment, animation, and hands
@onready var arrow_attach_position = $ArrowAttachPosition  # Empty node at the bowstring location
@onready var animation_player = $AnimationPlayer  # AnimationPlayer for the bow's draw animation
@onready var pickable_object = get_parent()  # Reference to the PickableObject parent node

@onready var right_hand_node = $"../GrabPointHandRight2"  # Adjust the path to your right hand node

func _ready():
	# Connect to the grabbed and released signals from the PickableObject
	pickable_object.connect("grabbed", Callable(self, "_on_grabbed"))
	pickable_object.connect("released", Callable(self, "_on_released"))
	if ArrowScene == null:
		print("Error: ArrowScene is null.")
	else:
		print("ArrowScene type:", typeof(ArrowScene))

func _process(delta):
	if is_drawing:
		# Synchronize with animation progress
		var animation_name = "ArmatureAction"  # Replace with your actual animation name
		var animation_length = animation_player.get_animation(animation_name).length
		var current_time = animation_player.current_animation_position
		var draw_percentage = current_time / animation_length
		draw_percentage = clamp(draw_percentage, 0.0, 1.0)

		# Calculate displacement along the x-axis
		var max_displacement = 0.5  # Adjust as needed (negative or positive depending on direction)
		var displacement = max_displacement * draw_percentage

		# Move arrow_attach_position back along the bow's local x-axis
		var attach_local_transform = arrow_attach_position.transform
		attach_local_transform.origin.x = displacement
		arrow_attach_position.transform = attach_local_transform

		# Move right hand to match
		if right_hand_node:
			right_hand_node.global_transform.origin = arrow_attach_position.global_transform.origin

		# Update draw_strength based on draw_percentage
		draw_strength = max_draw_strength * draw_percentage

# Signal handler for when the object is grabbed
func _on_grabbed(pickable, by):
	print("Grabbed by:", by.name)

	# Traverse up the hierarchy to determine which hand is grabbing
	var hand_name = _get_hand_name(by)
	print("Detected hand:", hand_name)
	if hand_name == "Left Hand" or hand_name == "GrabPointHandLeft":
		left_hand_grabbed = true
	elif hand_name == "Right Hand" or hand_name == "GrabPointHandRight":
		right_hand_grabbed = true

	print("Left hand grabbed:", left_hand_grabbed, "Right hand grabbed:", right_hand_grabbed)

	# Only start drawing when both hands are grabbing
	if left_hand_grabbed and right_hand_grabbed:
		start_drawing()

# Signal handler for when the object is released
func _on_released(pickable, by):
	print("Released by:", by.name)

	# Traverse up the hierarchy to determine which hand is releasing
	var hand_name = _get_hand_name(by)
	if hand_name == "Left Hand" or hand_name == "GrabPointHandLeft":
		left_hand_grabbed = false
	elif hand_name == "Right Hand" or hand_name == "GrabPointHandRight":
		right_hand_grabbed = false

	print("Left hand grabbed:", left_hand_grabbed, "Right hand grabbed:", right_hand_grabbed)

	# Release the arrow if either hand is released
	release_arrow()

# Helper function to traverse up the hierarchy and determine hand
func _get_hand_name(node):
	var current = node
	while current != null:
		print("Checking node:", current.name)  # Debug output for each node in the hierarchy
		if current.name == "Left Hand" or current.name == "GrabPointHandLeft":
			return "Left Hand"
		elif current.name == "Right Hand" or current.name == "GrabPointHandRight":
			return "Right Hand"
		current = current.get_parent()
	return null

# Function to start drawing the bow and attach the arrow
func start_drawing():
	print("Starting to draw the bow")
	if not is_drawing:
		is_drawing = true

		# Ensure ArrowScene is loaded correctly
		if ArrowScene == null:
			print("Error: ArrowScene could not be loaded.")
			return

		# Spawn a new arrow and attach it to the bowstring position
		arrow_instance = ArrowScene.instantiate() as RigidBody3D
		if arrow_instance == null:
			print("Error: arrow_instance is null after instantiation.")
			return

		arrow_instance.freeze = true  # Freeze the arrow while it's attached to the bow

		# Add the arrow as a child of arrow_attach_position
		arrow_attach_position.add_child(arrow_instance)
		arrow_instance.transform = Transform3D.IDENTITY  # Reset transform to align with parent

		# Play the draw animation
		var animation_name = "ArmatureAction"  # Replace with your actual animation name
		animation_player.play(animation_name)

# Function to release the arrow
func release_arrow():
	print("Releasing the arrow")
	if is_drawing and arrow_instance:
		# Stop drawing
		is_drawing = false

		# Calculate force based on draw strength
		var force = -arrow_instance.global_transform.basis.x * draw_strength  # Use basis.x for x-axis
		print("Draw strength:", draw_strength)
		print("Force applied:", force)

		# Preserve the arrow's global transform
		var arrow_global_transform = arrow_instance.global_transform

		# Detach the arrow and reparent it
		arrow_instance.get_parent().remove_child(arrow_instance)
		get_tree().get_root().add_child(arrow_instance)  # Or another appropriate node

		# Restore the global transform after reparenting
		arrow_instance.global_transform = arrow_global_transform

		# Unfreeze the arrow so physics will affect it
		arrow_instance.freeze = false

		# Apply the impulse and wake up the physics body
		arrow_instance.apply_impulse(Vector3.ZERO, force * 100)
		arrow_instance.sleeping = false

		# Reset draw strength
		draw_strength = 0.0
		arrow_instance = null

		# Reset arrow_attach_position position
		var attach_local_transform = arrow_attach_position.transform
		attach_local_transform.origin.x = 0
		arrow_attach_position.transform = attach_local_transform

		# Stop the animation or reset it
		animation_player.stop()  # Optional: Reset animation if needed
