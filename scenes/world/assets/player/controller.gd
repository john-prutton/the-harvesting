extends CharacterBody3D

@onready var flashlight = $"WGT-rig_head"/Item/Flashlight/SpotLight3D
@onready var axe = $"WGT-rig_head"/Item/Axe

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 6
const SENSITIVITY = 0.004
var mass = 2.5

#bob variables
const BOB_FREQ = 2.2
const BOB_AMP_Y = 0.08
const BOB_AMP_X = 0.05
var t_bob = 0.0
var step_timing = 0.8
var step = true

#sounds
var foot_steps: Array[Array]
@export var gravel_footsteps: Array[AudioStreamMP3]
@export var grass_footsteps: Array[AudioStreamMP3]

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.3

#animation
@onready var animationTree : AnimationTree = $AnimationTree

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.81

@onready var head = $"WGT-rig_head"
@onready var camera = $Camera3D
#@onready var item = $"WGT-rig_head/Item"
#@onready var audio_player = $AudioStreamPlayer3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	foot_steps = [gravel_footsteps,grass_footsteps]

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(80))
		#item.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(80))
	
	if event is InputEventMouseButton:
		var flash_used = Input.get_action_raw_strength("use_flashlight") > 0
		flashlight.visible = not flashlight.visible if flash_used else flashlight.visible
		
		var item_used = Input.get_action_raw_strength("use_item") > 0
		if item_used: (axe.get_node("AnimationPlayer") as AnimationPlayer).play("use_item")
	
	if event is InputEvent:
		if Input.is_action_just_pressed("jump"):	
			animationTree["parameters/conditions/is_idle"] = true

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity*mass * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	var raw_y = sin(time * BOB_FREQ)
	pos.y =  raw_y * BOB_AMP_Y
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP_X
	
	if (raw_y < -step_timing) and not step:
		_handle_audio()
		step = true
	elif raw_y > -step_timing: step = false
		
	return pos

func _handle_audio():
	var sound = foot_steps[1].pick_random()
	#audio_player.stream = sound
	#audio_player.play()
