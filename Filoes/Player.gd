extends KinematicBody

class_name Player

export var acceleration = 100
export var friction = 0.85
export var gravity = 80
export var jump_power = 30
export var mouse_sensitivity = 0.2

onready var HeadNode = $Head
onready var CameraNode = $Head/Camera


var vel = Vector3()
# _input() sets the value for a change whenever mouse moves
# aim() applies the change during _physics_process()
var camera_change = Vector2()


func _ready():
	# Capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	# Save mouse movement to the variable which will be used in aim()
	if event is InputEventMouseMotion:
		camera_change = event.relative
	# Release the mouse when I press Esc
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	aim()
	walk(delta)
	jump(delta)
	vel = move_and_slide(vel, Vector3.UP, true, 4) # , true, 4

func aim():
	if not camera_change.length(): return # if mouse was moved and camera needs to turn
	# Rotate horizontally
	HeadNode.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))
	# Rotate vertically
	CameraNode.rotate_x(deg2rad(-camera_change.y * mouse_sensitivity))
	# Limit rotation to 90 degrees
	# CameraNode.rotation.x = clamp(CameraNode.rotation.x,-deg2rad(60), deg2rad(60))
	# Reset camera change after it has been performed
	camera_change = Vector2()

	
func walk(delta):	
	# Basis contains 3 vectors, each vector points in the direction its axis has been rotated,
	# so they effectively describe the node’s total rotation.
	var head_rotation = HeadNode.get_global_transform().basis
	
	var move_direction = Vector3()
	# Direction vector based on where head is pointing at
	if Input.is_action_pressed("move_forward"):
		# Forward in godot is -z. So I move forward in the direction where head is pointing at
		move_direction -= head_rotation.z
	elif Input.is_action_pressed("move_back"):
		move_direction += head_rotation.z
	if Input.is_action_pressed("move_left"):
		move_direction -= head_rotation.x
	elif Input.is_action_pressed("move_right"):
		move_direction += head_rotation.x
	move_direction = move_direction.normalized()

	# Acceleration
	vel += move_direction*acceleration*delta
	# Friction
	vel *= friction
	# Gravity
	vel.y -= gravity*delta

func jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vel.y += jump_power
