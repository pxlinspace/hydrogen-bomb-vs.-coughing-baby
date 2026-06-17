extends Node

@onready var restart_timer: Timer = $RestartTimer
@onready var restart_bar: TextureProgressBar = $GUI/HUD/RestartBar
@onready var bomb_timer: Timer = $BombTimer
@onready var bomb_time_label: Label = $GUI/HUD/BombTimeLabel


func _process(_delta: float) -> void:
	if not restart_timer.is_stopped():
		restart_bar.value = 1.0 - restart_timer.time_left / restart_timer.wait_time
	var cs: float = bomb_timer.time_left * 100.0
	bomb_time_label.text = "%02d:%02d:%02d" % [fmod(cs/6000, 60), fmod(cs/100, 60), fmod(cs, 100)]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart_bar.show()
		restart_timer.start()
	if event.is_action_released("restart"):
		restart_bar.hide()
		restart_timer.stop()


func _on_restart_timer_timeout() -> void:
	get_tree().reload_current_scene()
