class_name Booster extends StaticBody2D

@onready var recovery_timer: Timer = $RecoveryTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var is_explodable: bool = true


func explode() -> void:
	animated_sprite_2d.play("explode")
	is_explodable = false
	recovery_timer.start()


func _on_recovery_timer_timeout() -> void:
	animated_sprite_2d.play("recover")
	is_explodable = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "recover":
		animated_sprite_2d.play("default")
