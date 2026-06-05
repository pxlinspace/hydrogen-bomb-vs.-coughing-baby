class_name Cougher extends Node2D

const COUGH_PARTICLES: PackedScene = preload("uid://02nwrd23es8q")
@onready var pause_timer: Timer = $PauseTimer
@onready var pause_timer_bar: TextureProgressBar = $PauseTimerBar
@onready var particle_container: Node2D = $ParticleContainer

func set_particle_rotation(angle: float) -> void:
	particle_container.rotation = angle

func cough() -> bool:
	if pause_timer.is_stopped():
		pause_timer.start()
		var particles: CPUParticles2D = COUGH_PARTICLES.instantiate()
		particles.emitting = true
		particle_container.add_child(particles)
		return true
	return false

func _process(_delta: float) -> void:
	pause_timer_bar.value = pause_timer.time_left / pause_timer.wait_time
