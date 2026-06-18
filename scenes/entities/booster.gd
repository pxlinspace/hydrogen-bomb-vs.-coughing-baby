class_name Booster extends StaticBody2D

var is_explodable: bool = true
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_animations: Node2D = $ExplosionAnimations


func explode() -> void:
	animated_sprite_2d.play("explode")
	for explosion_animation in explosion_animations.get_children():
		explosion_animation.play()
	is_explodable = false
	recovery_timer.start()


func _on_recovery_timer_timeout() -> void:
	animated_sprite_2d.play("recover")
	is_explodable = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "recover":
		animated_sprite_2d.play("default")
