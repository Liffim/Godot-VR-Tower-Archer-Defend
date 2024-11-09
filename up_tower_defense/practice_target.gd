extends Node3D

func hit_calc(position:Vector3):
	print_debug(position)
	print_debug($CollisionShape3D2.global_position)
	var distance = position.distance_to($CollisionShape3D2.global_position)
	print_debug(distance)
	if(distance < 0.21):
		display_text(10, "yellow", position)
	elif(distance < 0.25):
		display_text(8, "red", position)
	elif(distance < 0.30):
		display_text(6, "blue", position)
	elif(distance < 0.35):
		display_text(4, "black", position)
	else:
		display_text(2, "white", position)

func display_text(value, color, pos):
	var label_text = preload("res://hit_tooltip.tscn")
	var label_scene = label_text.instantiate()
	add_child(label_scene)
	label_scene.global_position = pos + Vector3(0.1, 0, 0)
	label_scene.set_color(color)
	label_scene.set_text(value)
	label_scene.go_up()
