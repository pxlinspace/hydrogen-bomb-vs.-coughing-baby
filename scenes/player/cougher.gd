class_name Cougher extends Node2D

signal touched_booster(booster_relative_position: Vector2)

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
@onready var detection_timer: Timer = $DetectionTimer
@onready var particle_area: Area2D = $ParticleArea
@onready var cough_sounds: Node = $CoughSounds
@onready var boost_sound: AudioStreamPlayer = $BoostSound


func play_cough_sound() -> void:
	cough_sounds.get_child(randi_range(0, cough_sounds.get_child_count()-1)).play()
	boost_sound.pitch_scale = randf_range(0.8, 1.2)
	boost_sound.play()


func set_particle_rotation(angle: float) -> void:
	particle_area.rotation = angle


func cough(angle: float = particle_area.rotation) -> bool:
	set_particle_rotation(angle)
	if pause_timer.is_stopped():
		pause_timer.start()
		pause_timer_bar.show()
		_play_cough_effects()
		particle_area.monitoring = true
		detection_timer.start()
		return true
	return false


func _on_detection_timer_timeout() -> void:
	particle_area.monitoring = false


func _play_cough_effects() -> void:
	var particles: CPUParticles2D = COUGH_PARTICLES.instantiate()
	particles.emitting = true
	particle_area.add_child(particles)
	play_cough_sound()


func _on_particle_area_body_entered(booster: Booster) -> void:
	booster.explode()
	touched_booster.emit(booster.global_position - global_position)


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
