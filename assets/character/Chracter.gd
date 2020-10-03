extends KinematicBody

const MAX_SPEED = 5
const JUMP_SPEED = 7
const ACCELERATION = 2
const DECELERATION = 4
const MAX_SLOPE_ANGLE = 30

onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity: Vector3



func _physics_process(delta):
	pass

#	# Apply gravity.
#	velocity.y += delta * gravity
#
#	# Using only the horizontal velocity, interpolate towards the input.
#	var hvel = velocity
#	hvel.y = 0
#
#	var acceleration
#	if dir.dot(hvel) > 0:
#		acceleration = ACCELERATION
#	else:
#		acceleration = DECELERATION
#
#	hvel = hvel.linear_interpolate(target, acceleration * delta)
#
#	# Assign hvel's values back to velocity, and then move.
#	velocity.x = hvel.x
#	velocity.z = hvel.z
#	velocity = move_and_slide(velocity, Vector3.UP)
#
#	# Jumping code. is_on_floor() must come after move_and_slide().
#	if is_on_floor() and Input.is_action_pressed("jump"):
#		velocity.y = JUMP_SPEED
#
