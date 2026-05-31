class_name Cougher extends Node2D

const COUGH_PARTICLES: PackedScene = preload("uid://02nwrd23es8q")

func cough() -> void:
	var particles: CPUParticles2D = COUGH_PARTICLES.instantiate()
	particles.emitting = true
	add_child(particles)
