extends RigidBody3D

var is_flying = false
@onready var timer = $Timer

func _physics_process(delta: float) -> void:
	if is_flying:
		if timer.is_stopped():
			timer.start()
		var direction = position + linear_velocity
		if direction != position:
			look_at(direction)
		if position.y <= -3:
			queue_free()

var hit = false

@onready var particles = $GPUParticles3D as GPUParticles3D
func start_burning():
	particles.visible = true
	particles.restart()
	
func stop_burning():
	particles.visible = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("arrow_collision") and not hit:
		is_flying = false
		hit = true
		freeze = true
		reparent(body)
		remove_child($CollisionShape3D)
		if body.has_method("hit_calc"):
			body.hit_calc($Area3D.global_position)


func _on_timer_timeout() -> void:
	queue_free()
