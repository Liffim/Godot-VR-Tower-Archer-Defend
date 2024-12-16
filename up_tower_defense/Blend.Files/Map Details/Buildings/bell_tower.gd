extends Node3D


var Animations : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Animations = get_children()[get_child_count()-2]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var belling = false
func start_belling():
	if not belling:
		belling = true
		$AudioStreamPlayer3D.play()
		await get_tree().create_timer(2.2).timeout
		Animations.play("RopeAction")
