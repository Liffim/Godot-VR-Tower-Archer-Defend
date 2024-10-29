extends Control

@export var target : Node3D
@onready var meter_text : Label = $Label/Label
var distance : int = 2

func _ready() -> void:
	update_text()
	
func _on_plus_pressed() -> void:
	distance += 1
	update_position(-1)
	update_text()

func update_text() -> void:
	meter_text.text = str(distance) + " m"

func update_position(x) -> void:
	target.position.x += x

func _on_minus_pressed() -> void:
	distance -= 1
	update_position(1)
	update_text()
