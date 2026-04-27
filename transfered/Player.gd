extends CharacterBody3D

var speed
const WALK_SPEED = 5
const SLOW_WALK_SPEED = 3
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 5
const SENSITIVITY = 0.0005
const GRAVITY_UP = 14.0
const GRAVITY_DOWN = 25.0
const CROUCH_SPEED = 1.2
const STAND_HEIGHT = 1.0
const CROUCH_HEIGHT = 0.5
const CROUCH_LERP = 10.0

# FOV
const BASE_FOV = 60.0
const FOV_CHANGE = 1.0

#BOB

const BOB_FREQ = 2.5
const BOB_AMP = 0.06
var t_bob = 3.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 17
var slow_walk = false
var crouching = false

@onready var head = $Head
@onready var camera = $Head/Camera3D

var step_timer = 0.0
var camera_rotation_x = 0.0
var head_tilt = 0.0
var camera_tilt_forward = 0.0
var current_speed = 5.0  # начальная скорость

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera_rotation_x -= event.relative.y * SENSITIVITY
		camera_rotation_x = clamp(camera_rotation_x, deg_to_rad(-90), deg_to_rad(90))
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y -= GRAVITY_UP * delta
		else:
			velocity.y -= GRAVITY_DOWN * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED 
		
		
	if Input.is_action_pressed("crouch"):
		crouching = true
		speed = CROUCH_SPEED
	else:
		crouching = false
		
	if Input.is_action_pressed("walk_slow"):
		slow_walk = true
		speed = SLOW_WALK_SPEED
	else:slow_walk = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Head tilt based on movement direction
	var target_tilt = input_dir.x * deg_to_rad(2)
	head_tilt = lerp(head_tilt, target_tilt, delta * 5.0)
	head.rotation.z = head_tilt
	
	# Camera tilt forward/backward
	var target_forward_tilt = -input_dir.y * deg_to_rad(2)
	camera_tilt_forward = lerp(camera_tilt_forward, target_forward_tilt, delta * 5.0)
	camera.rotation.x = camera_rotation_x + camera_tilt_forward
	if is_on_floor():
		if direction:
			
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 6.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 6.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0) #эти двое нужны для энерции в прыш
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
		
	#tBOBA
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	# CROUCH HEIGHT
	var target_height = STAND_HEIGHT
	
	if crouching:
		target_height = CROUCH_HEIGHT
	head.position.y = lerp(head.position.y, target_height, delta * CROUCH_LERP)
	
	
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
