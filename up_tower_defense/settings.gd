extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var modes = ["Continuous", "Snap"]
var mode = 0
var turns = [15, 30, 45]
var turn = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if($Visibility.visible):
		$Visibility/Label/ModeLabel.text = modes[mode]
		$Visibility/Label2/RadiusLabel.text = String.num(turns[turn]) + "°"
		if(modes[mode] == "Continuous"):
			CharacterGlobal.turn_mode = XRToolsMovementTurn.TurnMode.SMOOTH
		else:
			CharacterGlobal.turn_mode = XRToolsMovementTurn.TurnMode.SNAP
		CharacterGlobal.turn_radius = turns[turn]

func toggle_visible():
	$Visibility.visible = !$Visibility.visible
	


func _on_modeR_pressed() -> void:
	mode+=1
	if (mode >= 2):
		mode -= 2


func _on_modeL_pressed() -> void:
	mode-=1
	if (mode < 0):
		mode += 2


func _on_radiusR_pressed() -> void:
	turn+=1
	if (turn >= 3):
		turn -= 3


func _on_radiusL_pressed() -> void:
	turn-=1
	if (turn < 0):
		turn += 3


func _on_button_pressed() -> void:
	toggle_visible()
