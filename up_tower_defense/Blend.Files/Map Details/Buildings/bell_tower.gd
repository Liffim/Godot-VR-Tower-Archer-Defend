extends Node3D


var Animations : AnimationPlayer
@onready var timer : Timer = $WaveTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Animations = get_children()[get_child_count()-4]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func bell():
	_on_wave_timer_timeout()

func play_bell_anim():
	$AudioStreamPlayer3D.play(2.2)
	Animations.play("RopeAction")

var belling = false
func start_belling():
	if not belling:
		belling = true
		$AudioStreamPlayer3D.play()
		await get_tree().create_timer(2.2).timeout
		Animations.play("RopeAction")

func spawn(number):
	while number > 0:
		number-=1
		$"../SpawnPoints".get_children().pick_random().spawn()

var spawn_count = 3

func _on_wave_timer_timeout() -> void:
	spawn(spawn_count)
	timer.start()
	play_bell_anim()
	spawn_count+=2
