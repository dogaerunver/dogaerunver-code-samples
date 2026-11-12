extends CharacterBody3D

var speed: float = WALK_SPEED
const WALK_SPEED = 4.5
const SPRINT_SPEED = 7
const JUMP_VELOCITY = 7
const SENSITIVITY = 0.0065

#momentum variables
var momentum: float = 0.0
const MAX_MOMENTUM = 15.0
const SPRINT_JUMP_BOOST = 2.5
const WALL_JUMP_BOOST = 1.6
const MOMENTUM_DECAY = 2.0
const IDLE_MOMENTUM_DECAY = 15.0

#dash variables
const DASH_BOOST = 5.0
const DASH_COOLDOWN = 1.5
var dash_cooldown_timer := 0.0

#wall jump variables
const WALL_JUMP_FORWARD = 0.7
const WALL_JUMP_AWAY = 0.3
const WALL_JUMP_AIR_CONTROL_TIME = 0.35
var wall_jump_timer = 0.0

#slow (kinetic carbine) variables
const SLOW_DURATION = 2.5
const SLOW_MULTIPLIER = 0.3
var slow_timer = 0.0
var saved_velocity = Vector3.ZERO
var was_slowing = false

#bob variables
const BOB_FREQ = 2.6
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.2
const MOMENTUM_FOV_CHANGE = 0.15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 12

@onready var head = $Head
@onready var camera = $Head/Camera3D

@export var footstep_sounds: Array[AudioStream] = []
@export var jump_sound: AudioStream

const FOOTSTEP_INTERVAL = 0.5  # seconds at walking speed
var footstep_timer := 0.0
var last_footstep_index := -1

@onready var footstep_player = $FootstepPlayer
@onready var jump_player = $JumpPlayer

var spawn_position: Vector3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spawn_position = global_position
	jump_player.stream = jump_sound

func set_spawn_point(pos: Vector3):
	spawn_position = pos

func reset_to_spawn():
	global_position = spawn_position
	velocity = Vector3.ZERO
	momentum = 0.0
	speed = WALK_SPEED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta):
	# Handle Slow (right click hold).
	if Input.is_action_just_pressed("slow"):
		slow_timer = SLOW_DURATION
	if Input.is_action_just_released("slow"):
		slow_timer = 0.0
	if slow_timer > 0.0:
		slow_timer -= delta
	
	var slowing = slow_timer > 0.0
	
	# Save velocity at the start of slow, restore at the end.
	if slowing and not was_slowing:
		saved_velocity = velocity
	if not slowing and was_slowing:
		velocity = saved_velocity
	was_slowing = slowing
	
	if slowing:
		velocity = saved_velocity * SLOW_MULTIPLIER
		
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)
		
		var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped + MOMENTUM_FOV_CHANGE * momentum
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
		
		move_and_slide()
		return
	
	# Dash cooldown tick
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_player.pitch_scale = randf_range(0.95, 1.05)
			jump_player.play()
		elif is_on_wall():
			momentum = min(momentum + WALL_JUMP_BOOST, MAX_MOMENTUM)
			velocity.y = JUMP_VELOCITY
			var wall_normal = get_wall_normal()
			var forward = Vector3(velocity.x, 0, velocity.z).normalized()
			var push = forward * WALL_JUMP_FORWARD + wall_normal * WALL_JUMP_AWAY
			push = push.normalized() * speed
			velocity.x = push.x
			velocity.z = push.z
			wall_jump_timer = WALL_JUMP_AIR_CONTROL_TIME
			jump_player.pitch_scale = randf_range(0.95, 1.05)
			jump_player.play()
	
	# Handle Dash (sprint button).
	if Input.is_action_just_pressed("sprint") and dash_cooldown_timer <= 0.0:
		momentum = min(momentum + DASH_BOOST, MAX_MOMENTUM)
		dash_cooldown_timer = DASH_COOLDOWN
	
	# Handle speed.
	speed = lerp(speed, WALK_SPEED + momentum, delta * 2.0)
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Momentum decay
	if momentum > 0:
		if is_on_floor() and not direction:
			momentum = max(momentum - IDLE_MOMENTUM_DECAY * delta, 0.0)
		else:
			momentum = max(momentum - MOMENTUM_DECAY * delta, 0.0)
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 8.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 8.0)
	else:
		if wall_jump_timer > 0.0:
			wall_jump_timer -= delta
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 0.5)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 0.5)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped + MOMENTUM_FOV_CHANGE * momentum
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	# Footsteps
	if is_on_floor() and velocity.length() > 0.5:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			_play_footstep()
			footstep_timer = FOOTSTEP_INTERVAL * (WALK_SPEED / max(velocity.length(), 1.0))
	else:
		footstep_timer = 0.0
	
	move_and_slide()

func _play_footstep():
	if footstep_sounds.is_empty():
		return
	var idx = randi() % footstep_sounds.size()
	if footstep_sounds.size() > 1:
		while idx == last_footstep_index:
			idx = randi() % footstep_sounds.size()
	last_footstep_index = idx
	
	footstep_player.stream = footstep_sounds[idx]
	footstep_player.pitch_scale = randf_range(0.9, 1.1)
	footstep_player.play()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
	return pos
