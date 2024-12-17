extends Node3D

@export var text : String = "Lorem Ipsum"
@onready var label : Label3D = $Text

func _ready() -> void:
	$Text.text = ""

func make_visible() -> void:
	label.text = text
	
func make_invisible() -> void:
	label.text = ""


func _on_viewport_2_din_3d_pointer_event(event: Variant) -> void:
	var typedEvent = event as XRToolsPointerEvent
	if typedEvent.event_type == XRToolsPointerEvent.Type.ENTERED:
		make_visible()
	if typedEvent.event_type == XRToolsPointerEvent.Type.EXITED:
		make_invisible()
	var player = $"../../../XROrigin3D"
	if player != null:
		look_at($"../../../XROrigin3D".position)
