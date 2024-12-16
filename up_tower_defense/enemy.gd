extends CharacterBody3D

@onready var mesh : MeshInstance3D

var speed = 1.3
var health = 20

var material : Material

func _ready() -> void:
	mesh = $MeshInstance3D
	material = mesh.mesh.surface_get_material(0).duplicate()
	mesh.set_surface_override_material(0, material)

func _process(delta: float) -> void:
	if health <= 0:
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = (get_parent().position + position).direction_to(CharacterGlobal.player_position) * speed
	velocity.y = -1
	move_and_slide()

func hit_calc(position:Vector3):
	var dmg = randi_range(6, 12)
	await create_tween().tween_property(material, "albedo_color", Color.WHITE, 0.04).finished
	create_tween().tween_property(material, "albedo_color", Color("890000"), 0.6)
	health -= dmg
	display_text(dmg, global_position)

func display_text(value, pos):
	var label_text = preload("res://hit_tooltip.tscn")
	var label_scene = label_text.instantiate()
	add_child(label_scene)
	label_scene.global_position = pos + Vector3(0, 1, 0)
	label_scene.set_color("white")
	label_scene.set_size(2)
	label_scene.set_text(value)
	label_scene.go_up()
