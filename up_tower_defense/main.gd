extends Node3D

var xr_interface: XRInterface

func _ready():
	CharacterGlobal.hit_shots = 0
	CharacterGlobal.total_shots = 0
	CharacterGlobal.kills = 0
	CharacterGlobal.time = 0
	
	xr_interface = XRServer.find_interface("OpenXR")
	
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialised successfully")
		
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		print("OpenXr failed")

var enemy_count = 0

var game_ended = false
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Enemy"):
		enemy_count+=1
	if enemy_count >= 4 and not game_ended:
		end_game("Your tower has collapsed")
		
@onready var tower : Node3D = $Tower
func end_game(message):
	game_ended = true
	$XROrigin3D.reparent($Tower)
	create_tween().tween_method(rotate_tower, 0, 90, 2.5)
	await create_tween().tween_property(CharacterGlobal.fade, "modulate", Color.BLACK, 3).set_ease(Tween.EASE_IN_OUT).finished
	get_tree().change_scene_to_file("res://end_scene.tscn")

func rotate_tower(deg):
	tower.rotation.z = deg_to_rad(deg)


func _on_timer_timeout() -> void:
	CharacterGlobal.time += 1
