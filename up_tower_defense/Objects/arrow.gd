extends RigidBody3D

func _process(delta: float) -> void:
	if not freeze:
		print_debug(linear_velocity)
		
func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 0:
		var direction = position + linear_velocity
		look_at(direction)

var hit = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("arrow_collision") and not hit:
		hit = true
		freeze = true
		reparent(body)
		remove_child($CollisionShape3D)
		if body.has_method("hit_calc"):
			body.hit_calc($Area3D.global_position)
