extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var spawned = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not spawned and CharacterGlobal.player_position.y >= 5:
		spawned = true
		await get_tree().create_timer(randi_range(5,12)*randi_range(1,3)).timeout
		var enemy_scene = preload("res://enemy.tscn")
		var enemy_spawned = enemy_scene.instantiate()
		add_child(enemy_spawned)
