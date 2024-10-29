extends RigidBody3D



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("arrow_collision"):
		freeze = true
		if body.has_method("hit_calc"):
			body.hit_calc($Area3D.global_position)
