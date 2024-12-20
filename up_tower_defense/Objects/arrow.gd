extends RigidBody3D

var is_flying = false
@onready var timer = $Timer

var shot_count = false

func _physics_process(delta: float) -> void:
	if is_flying:
		if not shot_count:
			shot_count = true
			CharacterGlobal.total_shots+=1
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
			if $GPUParticles3D.visible and body.has_method("set_on_fire"):
				body.set_on_fire()
		if body.has_method("bell"):
			body.bell()


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	CharacterGlobal.burning_arrow = true
