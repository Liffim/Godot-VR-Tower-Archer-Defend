extends Node3D

func spawn():
	await get_tree().create_timer(randi_range(5,12)*randi_range(1,3)).timeout
	var enemy_scene = preload("res://enemy.tscn")
	var enemy_spawned = enemy_scene.instantiate()
	enemy_spawned.global_position = global_position
	enemy_spawned.name = "Enemy" + str(randi())
	$"../..".add_child(enemy_spawned)
