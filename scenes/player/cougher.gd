class_name Cougher extends Node2D

const COUGH_PARTICLES: PackedScene = preload("uid://02nwrd23es8q")
const TWEEN_DURATION: float = 0.3
const INITIAL_CHARGED_RING_RADIUS: float = 14.0
const MAX_CHARGED_RING_RADIUS: float = 24.0
const MAX_CHARGED_RING_WIDTH: float = 6.0
var _charged_ring_radius: float = INITIAL_CHARGED_RING_RADIUS
var _charged_ring_width: float = 0.0
var _is_tweening: bool = false

@onready var pause_timer: Timer = $PauseTimer
@onready var pause_timer_bar: TextureProgressBar = $PauseTimerBar
@onready var particle_container: Node2D = $ParticleContainer


func set_particle_rotation(angle: float) -> void:
	particle_container.rotation = angle


func cough() -> bool:
	if pause_timer.is_stopped():
		pause_timer.start()
		pause_timer_bar.show()
		var particles: CPUParticles2D = COUGH_PARTICLES.instantiate()
		particles.emitting = true
		particle_container.add_child(particles)
		return true
	return false


func _process(_delta: float) -> void:
	if not pause_timer.is_stopped():
		pause_timer_bar.value = 1.0 - pause_timer.time_left / pause_timer.wait_time
	if _is_tweening:
		queue_redraw()


func _on_pause_timer_timeout() -> void:
	pause_timer_bar.hide()
	
	_is_tweening = true
	_charged_ring_width = MAX_CHARGED_RING_WIDTH
	_charged_ring_radius = INITIAL_CHARGED_RING_RADIUS
	queue_redraw()
	var radius_tween := create_tween()
	radius_tween.tween_property(self, "_charged_ring_radius", MAX_CHARGED_RING_RADIUS, TWEEN_DURATION) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	var width_tween := create_tween()
	width_tween.tween_property(self, "_charged_ring_width", 0.0, TWEEN_DURATION) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	width_tween.tween_callback(func() -> void:
		_charged_ring_radius = 0
		_is_tweening = false
		queue_redraw()
	)


func _draw() -> void:
	if _is_tweening:
		draw_circle(Vector2.ZERO, _charged_ring_radius, Color.WHITE, false, _charged_ring_width)
