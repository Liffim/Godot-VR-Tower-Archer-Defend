extends Node3D

var ArrowScene = load("res://Objects/arrow.tscn") as PackedScene

var arrow_instance: RigidBody3D = null
var draw_strength: float = 0.0
var max_draw_strength: float = 20.0
var is_drawing: bool = false
var left_hand_grabbed: bool = false
var right_hand_grabbed: bool = false

# Added gravity scale for better arrow trajectory
var arrow_gravity_scale: float = 1.5  # Adjust this value to control arrow drop

@onready var arrow_attach_position = $ArrowAttachPosition
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var pickable_object = get_parent()
@onready var right_hand_node = $"../GrabPointHandRight2"

func _ready():
	pickable_object.connect("grabbed", Callable(self, "_on_grabbed"))
	pickable_object.connect("released", Callable(self, "_on_released"))
	if ArrowScene == null:
		print("Error: ArrowScene is null.")
	else:
		print("ArrowScene type:", typeof(ArrowScene))

@onready var bow_pickable : RigidBody3D = $".."
func _process(delta):
	if holstered:
		bow_pickable.freeze = true
		bow_pickable.rotation = Vector3(0,0,0)
		bow_pickable.rotation.z = deg_to_rad(90)
		bow_pickable.global_position = CharacterGlobal.holster_position
	else:
		bow_pickable.freeze = false
	
	if is_drawing:
		#var bow_all = $"."
		#bow_all.look_at(bow_all.global_position + CharacterGlobal.right_position.direction_to(CharacterGlobal.left_position))
		var animation_name = "ArmatureAction"
		var animation_length = animation_player.get_animation(animation_name).length
		#var current_time = animation_player.current_animation_position
		#var draw_percentage = current_time / animation_length
		var draw_percentage = $ArrowAttachPosition.global_position.distance_to(CharacterGlobal.right_position) * 3
		draw_percentage = clamp(draw_percentage, 0.0, 1.0)
		CharacterGlobal.rumbler.event.magnitude = draw_percentage - 0.3
		var anim_pos = clamp(draw_percentage-0.1, 0.0, 1.0)
		animation_player.seek(animation_length * anim_pos - draw_percentage * animation_length * 0.08, true, true)

		var max_displacement = 0.35
		var displacement = max_displacement * draw_percentage

		var attach_local_transform = arrow_attach_position.transform
		attach_local_transform.origin.x = displacement
		arrow_attach_position.transform = attach_local_transform

		if right_hand_node:
			right_hand_node.global_transform.origin = arrow_attach_position.global_transform.origin

		draw_strength = max_draw_strength * draw_percentage

func _on_grabbed(pickable, by):
	var hand_name = _get_hand_name(by)
	holstered = false
	if hand_name == "Left Hand" or hand_name == "GrabPointHandLeft":
		left_hand_grabbed = true
	elif hand_name == "Right Hand" or hand_name == "GrabPointHandRight":
		right_hand_grabbed = true

	if left_hand_grabbed and right_hand_grabbed:
		start_drawing()

var holstered = true

func _on_released(pickable, by):
	var hand_name = _get_hand_name(by)
	if hand_name == "Left Hand" or hand_name == "GrabPointHandLeft":
		left_hand_grabbed = false
	elif hand_name == "Right Hand" or hand_name == "GrabPointHandRight":
		right_hand_grabbed = false
		
	if not (left_hand_grabbed or right_hand_grabbed):
		holstered = true

	release_arrow()

func _get_hand_name(node):
	var current = node
	while current != null:
		if current.name == "Left Hand" or current.name == "GrabPointHandLeft":
			return "Left Hand"
		elif current.name == "Right Hand" or current.name == "GrabPointHandRight":
			return "Right Hand"
		current = current.get_parent()
	return null

func start_drawing():
	CharacterGlobal.drawing = true
	CharacterGlobal.rumbler.rumble()
	print("Starting to draw the bow")
	if not is_drawing:
		is_drawing = true

		# Ensure ArrowScene is loaded correctly
		if ArrowScene == null:
			print("Error: ArrowScene could not be loaded.")
			return
		
		if CharacterGlobal.arrow:
			CharacterGlobal.drawing_arrow = true
			CharacterGlobal.arrow = false
			# Spawn a new arrow and attach it to the bowstring position
			arrow_instance = ArrowScene.instantiate() as RigidBody3D
			if arrow_instance == null:
				print("Error: arrow_instance is null after instantiation.")
				return

			arrow_instance.freeze = true  # Freeze the arrow while it's attached to the bow
			
			# Add the arrow as a child of arrow_attach_position
			arrow_attach_position.add_child(arrow_instance)
			arrow_instance.transform = Transform3D.IDENTITY  # Reset transform to align with parent
			if CharacterGlobal.burning_arrow:
				call_deferred("start_burning")
			CharacterGlobal.burning_arrow = false
			# Set arrow's global transform to match arrow_attach_position
			arrow_instance.global_transform = arrow_attach_position.global_transform

		# Play the draw animation
		var animation_name = "ArmatureAction"  # Replace with your actual animation name
		animation_player.play(animation_name)
		animation_player.pause()

func start_burning():
	arrow_instance.start_burning()

func release_arrow():
	CharacterGlobal.rumbler.cancel()
	print("Releasing the arrow")
	if is_drawing:
		# Stop drawing
		is_drawing = false
		CharacterGlobal.drawing = false
		if CharacterGlobal.drawing_arrow and arrow_instance:
			# Get the arrow's global transform from the arrow_attach_position
			var arrow_global_transform = arrow_attach_position.global_transform

			# Detach the arrow and reparent it
			arrow_instance.get_parent().remove_child(arrow_instance)
			get_tree().current_scene.add_child(arrow_instance)

			# Restore the global transform after reparenting
			arrow_instance.global_transform = arrow_global_transform

			# Unfreeze the arrow so physics will affect it
			arrow_instance.freeze = false
			arrow_instance.is_flying = true

			# Ensure the arrow is awake
			arrow_instance.sleeping = false  # Set sleeping to false to wake up the body

			# Optionally set gravity scale
			arrow_instance.gravity_scale = arrow_gravity_scale

			# Calculate force based on draw strength
			var direction = -arrow_instance.global_transform.basis.z.normalized()
			var force = direction * draw_strength
			print("Draw strength:", draw_strength)
			print("Direction:", direction)
			print("Force applied:", force)

			# Apply the impulse
			arrow_instance.apply_central_impulse(force)

			# Reset draw strength and arrow instance
			draw_strength = 0.0
			arrow_instance = null
		CharacterGlobal.drawing_arrow = false
		# Reset arrow_attach_position position
		var attach_local_transform = arrow_attach_position.transform
		attach_local_transform.origin.x = 0
		arrow_attach_position.transform = attach_local_transform

		# Stop the animation
		animation_player.stop()
