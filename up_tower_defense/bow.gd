@tool
class_name XRToolsPickable
extends RigidBody3D

# Signals
signal picked_up(pickable)
signal dropped(pickable)
signal grabbed(pickable, by)
signal released(pickable, by)
signal action_pressed(pickable)
signal highlight_updated(pickable, enable)

# Enums
enum RangedMethod {
	NONE,
	SNAP,
	LERP,
}

enum ReleaseMode {
	ORIGINAL = -1,
	UNFROZEN = 0,
	FROZEN = 1,
}

enum SecondHandGrab {
	IGNORE,
	SWAP,
	SECOND,
}

# Preload the arrow scene
var ArrowScene = preload("res://Objects/arrow.tscn")

# Variables for arrow spawning and shooting
var arrow_instance: RigidBody3D = null
var draw_strength: float = 0.0
var max_draw_strength: float = 30.0  # Adjust as needed for force
var is_drawing: bool = false

# Nodes for arrow attachment and animation
@onready var arrow_attach_position = $bow_low_w_anims/ArrowAttachPosition  # Add this as an empty node at the bowstring location
@onready var animation_player = $bow_low_w_anims/AnimationPlayer  # AnimationPlayer for the bow's draw animation

# Other settings
@export var enabled : bool = true
@export var press_to_hold : bool = true
@export_flags_3d_physics var picked_up_layer : int = 0b0000_0000_0000_0001_0000_0000_0000_0000
@export var release_mode : ReleaseMode = ReleaseMode.ORIGINAL
@export var ranged_grab_method : RangedMethod = RangedMethod.SNAP: set = _set_ranged_grab_method
@export var second_hand_grab : SecondHandGrab = SecondHandGrab.IGNORE
@export var ranged_grab_speed : float = 20.0
@export var picked_by_exclude : String = ""
@export var picked_by_require : String = ""

var can_ranged_grab: bool = true
var restore_freeze : bool = false
var _grab_driver: XRToolsGrabDriver = null
var _grab_points : Array[XRToolsGrabPoint] = []
var _highlight_requests : Dictionary = {}
var _highlighted : bool = false
@onready var original_collision_mask : int = collision_mask
@onready var original_collision_layer : int = collision_layer

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get all grab points
	for child in get_children():
		var grab_point := child as XRToolsGrabPoint
		if grab_point:
			_grab_points.push_back(grab_point)
	
	# Connect signals for grabbing and releasing
	connect("grabbed", self, "_on_grabbed")
	connect("released", self, "_on_released")

# Signal handler for when the object is grabbed
func _on_grabbed(pickable, by):
	start_drawing()

# Signal handler for when the object is released
func _on_released(pickable, by):
	release_arrow()

# Function to start drawing the bow and attach the arrow
func start_drawing():
	if not is_drawing:
		is_drawing = true
		
		# Spawn a new arrow and attach it to the bowstring position
		arrow_instance = ArrowScene.instance() as RigidBody3D
		arrow_instance.transform = arrow_attach_position.global_transform
		add_child(arrow_instance)

		# Play the draw animation
		animation_player.play("draw_animation")  # Replace "draw_animation" with the actual name of your animation

# Function to release the arrow
func release_arrow():
	if is_drawing and arrow_instance:
		# Stop drawing
		is_drawing = false
		
		# Calculate force based on draw strength
		var force = -arrow_instance.transform.basis.z * draw_strength
		
		# Detach the arrow and apply impulse
		arrow_instance.get_parent().remove_child(arrow_instance)
		add_child(arrow_instance)  # Move arrow to root of scene for independent physics
		arrow_instance.apply_impulse(Vector3(), force)
		
		# Reset draw strength
		draw_strength = 0.0
		arrow_instance = null
		
		# Stop the animation or reset it
		animation_player.stop()  # Optional: Reset animation if needed

# Method for ranged grabbing and release
func _set_ranged_grab_method(new_value: int) -> void:
	ranged_grab_method = new_value
	can_ranged_grab = new_value != RangedMethod.NONE

# Additional methods and overrides from the original script
func action():
	emit_signal("action_pressed", self)

func drop():
	if not is_picked_up():
		return

	if _grab_driver.secondary:
		_grab_driver.secondary.by.drop_object()
	_grab_driver.primary.by.drop_object()

func drop_and_free():
	drop()
	queue_free()

func pick_up(by: Node3D) -> void:
	if not enabled:
		return

	var grabber := Grabber.new(by)

	if is_picked_up():
		if second_hand_grab == SecondHandGrab.IGNORE:
			return

		if not _grab_driver.primary.pickup or not grabber.pickup:
			return

		if second_hand_grab != SecondHandGrab.SWAP:
			var by_grab_point := _get_grab_point(by, _grab_driver.primary.point)
			var grab := Grab.new(grabber, self, by_grab_point, true)
			_grab_driver.add_grab(grab)
			grabbed.emit(self, by)
			return

		let_go(_grab_driver.primary.by, Vector3.ZERO, Vector3.ZERO)

	match release_mode:
		ReleaseMode.UNFROZEN:
			restore_freeze = false
		ReleaseMode.FROZEN:
			restore_freeze = true
		_:
			restore_freeze = freeze

	freeze = true
	collision_layer = picked_up_layer
	collision_mask = 0

	var by_grab_point := _get_grab_point(by, null)
	if by.picked_up_ranged:
		if ranged_grab_method == RangedMethod.LERP:
			var grab := Grab.new(grabber, self, by_grab_point, false)
			_grab_driver = XRToolsGrabDriver.create_lerp(self, grab, ranged_grab_speed)
		else:
			var grab := Grab.new(grabber, self, by_grab_point, false)
			_grab_driver = XRToolsGrabDriver.create_snap(self, grab)
	else:
		var grab := Grab.new(grabber, self, by_grab_point, true)
		_grab_driver = XRToolsGrabDriver.create_snap(self, grab)

	picked_up.emit(self)
	grabbed.emit(self, by)

func let_go(by: Node3D, p_linear_velocity: Vector3, p_angular_velocity: Vector3) -> void:
	if not is_picked_up():
		return

	var grab := _grab_driver.get_grab(by)
	if not grab:
		return

	_grab_driver.remove_grab(grab)
	grab.release()

	if _grab_driver.primary:
		if is_instance_valid(_grab_driver.primary.hand_point):
			if _grab_driver.primary.hand_point.mode != XRToolsGrabPointHand.Mode.SECONDARY:
				return
			var new_grab_point := _get_grab_point(_grab_driver.primary.by, null)
			switch_active_grab_point(new_grab_point)
		return

	_grab_driver.discard()
	_grab_driver = null

	freeze = restore_freeze
	collision_mask = original_collision_mask
	collision_layer = original_collision_layer
	linear_velocity = p_linear_velocity
	angular_velocity = p_angular_velocity
	dropped.emit(self)

func get_picked_up_by() -> Node3D:
	if not is_picked_up():
		return null
	return _grab_driver.primary.by

func _get_grab_point(grabber : Node3D, current : XRToolsGrabPoint) -> XRToolsGrabPoint:
	var fitness := 0.0
	var point : XRToolsGrabPoint = null
	for p in _grab_points:
		var f := p.can_grab(grabber, current)
		if f > fitness:
			fitness = f
			point = p
	while point is XRToolsGrabPointRedirect:
		point = point.target
	return point
