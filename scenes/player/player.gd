extends CharacterBody2D

@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var cougher: Cougher = $Cougher

const GROUND_ACCELERATION: float = 800.0
const AIR_ACCELERATION: float = 600.0
const SPEED: float = 250.0
const COUGH_SPEED: float = 350.0
const JUMP_VELOCITY: float = -300.0
const GRAVITY: float = 650.0
const DIVE_GRAVITY: float = 1200.0
const MAX_Y_VELOCITY: float = 500.0
const MAX_DIVE_Y_VELOCITY: float = 700.0
const HIT_POWER: float = 100.0

func _physics_process(delta: float) -> void:
	cougher.set_particle_rotation(get_local_mouse_position().angle())
	process_movement(delta)

func process_movement(delta: float) -> void:
	var was_on_floor: bool = is_on_floor()
	if not was_on_floor:
		var gravity: float = GRAVITY
		var max_y_velocity: float = MAX_DIVE_Y_VELOCITY
		if Input.is_action_pressed("dive"):
			gravity = DIVE_GRAVITY
			max_y_velocity = MAX_DIVE_Y_VELOCITY
		velocity.y = move_toward(velocity.y, max_y_velocity, gravity * delta)

	var direction: float = Input.get_axis("left", "right")
	var acceleration: float = (GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION) * delta
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration)

	move_and_slide()
	
	if was_on_floor and not is_on_floor():
		coyote_jump_timer.start()
	if is_on_floor() and not jump_buffer_timer.is_stopped():
		jump_buffer_timer.stop()
		velocity.y = JUMP_VELOCITY


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if is_on_floor() or not coyote_jump_timer.is_stopped():
			velocity.y = JUMP_VELOCITY
			coyote_jump_timer.stop()
		else:
			jump_buffer_timer.start()
	
	if event.is_action_pressed("dive") and not is_on_floor():
		velocity.y = 100.0
	
	if event.is_action_pressed("cough"):
		if cougher.cough():
			velocity = -get_local_mouse_position().normalized() * COUGH_SPEED
