extends KinematicBody

const MAX_SPEED = 5
const JUMP_SPEED = 7
const ACCELERATION = 2
const DECELERATION = 4
const MAX_SLOPE_ANGLE = 30

onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity: Vector3


func display(_viewport, _camera):
	pass
	# viewport = self
	# viewport.add_child(self)
	# camera.set_transform(self.get_transform())
	# camera.translate(Vector3(1, 0, 1))
	
func _ready():
	$Sprite3D.play("idle")


func moving():
	$Sprite3D.play("walking")


func idle():
	$Sprite3D.play("idle")


func move_now(cell):
	translate(cell - get_global_transform().origin)


func move(delta, dir):
	# Get the camera's transform basis, but remove the X rotation such
	# that the Y axis is up and Z is horizontal.
	# var cam_basis = $Camera.global_transform.basis
	# var basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
	# dir = basis.xform(dir)
	
	# Limit the input to a length of 1. length_squared is faster to check.
	if dir.length_squared() > 1:
		dir /= dir.length()

	# Apply gravity.
	velocity.y += delta * gravity

	# Using only the horizontal velocity, interpolate towards the input.
	var hvel = velocity
	hvel.y = 0

	var target = dir * MAX_SPEED
	var acceleration
	
	if dir.dot(hvel) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DECELERATION

	hvel = hvel.linear_interpolate(target, acceleration * delta)

	# Assign hvel's values back to velocity, and then move.
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity.y = hvel.y
	velocity = move_and_slide(velocity, Vector3.UP)


func _physics_process(delta):
	move(delta, Vector3(0, -1, 0))
