class_name Cougher extends Node2D

const COUGH_PARTICLES = preload("uid://02nwrd23es8q")

func cough():
	var particles = COUGH_PARTICLES.instantiate()
	particles.emitting = true
	add_child(particles)
