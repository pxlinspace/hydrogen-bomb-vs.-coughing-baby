extends CharacterBody2D


const GROUND_ACCELERATION: float = 1600.0
const AIR_ACCELERATION: float = 800.0
const SPEED: float = 250.0
const COUGH_SPEED: float = 350.0
const JUMP_VELOCITY: float = -220.0
const WALL_JUMP_VELOCITY := Vector2(200, -300)
const INITIAL_DIVE_VELOCITY: float = 200.0
const INITIAL_DIVE_HORIZONTAL_FACTOR: float = 0.75
const GRAVITY: float = 800.0
const DIVE_GRAVITY: float = 1200.0
const MAX_Y_VELOCITY: float = 500.0
const MAX_DIVE_Y_VELOCITY: float = 700.0
const HIT_POWER: float = 100.0

@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var jump_duration_timer: Timer = $JumpDurationTimer
@onready var cougher: Cougher = $Cougher
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: float = 1.0


func _physics_process(delta: float) -> void:
	_process_movement(delta)
	_update_animation()


func _update_animation() -> void:
	var anim: String = sprite.animation
	if sprite.is_playing() and (anim == "cough_side" or anim =="cough_down" or anim == "cough_up"):
		return
	
	if is_on_wall_only():
		sprite.flip_h = get_wall_normal().x > 0
	elif Input.is_action_pressed("left"):
		sprite.flip_h = true
	elif Input.is_action_pressed("right"):
		sprite.flip_h = false
	
	if is_on_floor():
		sprite.play("default" if velocity.x == 0 else "walk")
	elif Input.is_action_pressed("dive"):
		sprite.play("dive")
	elif is_on_wall_only():
		sprite.play("wall")
	else:
		sprite.play("jump_fall" if velocity.y > 0 else "jump_rise")


func _process_movement(delta: float) -> void:
	var was_on_floor: bool = is_on_floor()
	if not was_on_floor and jump_duration_timer.is_stopped():
		var gravity: float = GRAVITY
		var max_y_velocity: float = MAX_DIVE_Y_VELOCITY
		if Input.is_action_pressed("dive"):
			gravity = DIVE_GRAVITY
			max_y_velocity = MAX_DIVE_Y_VELOCITY
		velocity.y = move_toward(velocity.y, max_y_velocity, gravity * delta)

	var direction: float = Input.get_axis("left", "right")
	if direction != 0:
		last_direction = direction
	
	var acceleration: float = (GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION) * delta
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration)

	move_and_slide()
	
	if was_on_floor and not is_on_floor():
		coyote_jump_timer.start()
	if not jump_buffer_timer.is_stopped():
		if is_on_floor():
			jump_buffer_timer.stop()
			_apply_jump()
		elif is_on_wall_only():
			_apply_wall_jump()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if is_on_floor() or not coyote_jump_timer.is_stopped():
			_apply_jump()
			coyote_jump_timer.stop()
		elif is_on_wall_only():
			_apply_wall_jump()
		else:
			jump_buffer_timer.start()
	if event.is_action_released("jump"):
		_stop_jump()
	
	if event.is_action_pressed("dive") and not is_on_floor():
		velocity.x *= INITIAL_DIVE_HORIZONTAL_FACTOR
		velocity.y = INITIAL_DIVE_VELOCITY
	
	if event.is_action_pressed("cough"):
		var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
		if direction == Vector2.ZERO:
			direction = Vector2(last_direction, 0)
		if cougher.cough((-direction).angle()):
			_apply_cough_impulse(direction)


func _apply_cough_impulse(direction: Vector2) -> void:
	velocity = direction * COUGH_SPEED
	if velocity.x != 0:
		sprite.play("cough_side")
	elif velocity.y < 0:
		sprite.play("cough_down")
	else:
		sprite.play("cough_up")


func _apply_jump() -> void:
	jump_duration_timer.start()
	velocity.y = JUMP_VELOCITY


func _stop_jump() -> void:
	jump_duration_timer.stop()


func _apply_wall_jump() -> void:
	velocity.y = WALL_JUMP_VELOCITY.y
	velocity.x = WALL_JUMP_VELOCITY.x * (-1 if get_wall_normal().x < 0 else 1)
