extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Kills.text += str(CharacterGlobal.kills)
	$Accuracy.text += str(CharacterGlobal.hit_shots) + "/" + str(CharacterGlobal.total_shots)
	var mins = CharacterGlobal.time / 60
	var secs = CharacterGlobal.time % 60
	$Time.text += str(mins) + "m " + str(secs) + "s"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
