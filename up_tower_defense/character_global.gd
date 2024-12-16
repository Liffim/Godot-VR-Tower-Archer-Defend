extends Node

var player_position : Vector3
var left_position : Vector3
var right_position : Vector3
var rumbler : XRToolsRumbler
var burning_arrow : bool = false
var arrow : bool = false
var drawing : bool = false
var drawing_arrow : bool = false
var holster : bool = false
var holster_position : Vector3
var holster_rotation : float
var fade : Sprite3D
var turn_mode = XRToolsMovementTurn.TurnMode.SMOOTH
var turn_radius = 15.0
