extends Node3D  # Attach this to the `bow_low_w_anims` node

# Preload the arrow scene and ensure it is treated as a PackedScene
var ArrowScene = preload("res://Objects/arrow.tscn")

# Variables for arrow spawning and shooting
var arrow_instance: RigidBody3D = null
var draw_strength: float = 0.0
var max_draw_strength: float = 30.0  # Adjust as needed for force
var is_drawing: bool = false
var left_hand_grabbed: bool = false
var right_hand_grabbed: bool = false

# Nodes for arrow attachment and animation
@onready var arrow_attach_position = $ArrowAttachPosition2 # Add this as an empty node at the bowstring location
@onready var animation_player = $AnimationPlayer  # AnimationPlayer for the bow's draw animation
@onready var pickable_object = get_parent()  # Reference to the PickableObject parent node

func _ready():
	# Connect to the grabbed and released signals from the PickableObject
	pickable_object.connect("grabbed", Callable(self, "_on_grabbed"))
	pickable_object.connect("released", Callable(self, "_on_released"))
	if ArrowScene == null:
		print("Error: ArrowScene is null.")
	else:
		print("ArrowScene type:", typeof(ArrowScene))

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
		arrow_instance = ArrowScene.instance() as RigidBody3D
		arrow_instance.transform = arrow_attach_position.global_transform
		add_child(arrow_instance)

		# Play the draw animation
		animation_player.play("ArmatureAction")  # Replace "ArmatureAction" with the actual name of your animation

# Function to release the arrow
func release_arrow():
	print("Releasing the arrow")
	if is_drawing and arrow_instance:
		# Stop drawing
		is_drawing = false
		
		# Calculate force based on draw strength
		var force = -arrow_instance.transform.basis.z * draw_strength
		
		# Detach the arrow and apply impulse
		arrow_instance.get_parent().remove_child(arrow_instance)
		get_parent().add_child(arrow_instance)  # Move arrow to root of scene for independent physics
		arrow_instance.apply_impulse(Vector3(), force)
		
		# Reset draw strength
		draw_strength = 0.0
		arrow_instance = null
		
		# Stop the animation or reset it
		animation_player.stop()  # Optional: Reset animation if needed
