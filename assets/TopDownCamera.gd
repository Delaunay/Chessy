extends KinematicBody

const MAX_SPEED = 12
const ACCELERATION = 2
const DECELERATION = 4
const MAX_SLOPE_ANGLE = 30

var velocity: Vector3

func _physics_process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("reset_position"):
		translation = Vector3(-3, 4, 8)
	
	var dir = Vector3()
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	dir.y = int(Input.is_action_just_released("zoom_out")) - int(Input.is_action_just_released("zoom_in"))
	
	
	# Get the camera's transform basis, but remove the X rotation such
	# that the Y axis is up and Z is horizontal.
	var cam_basis = $Camera.global_transform.basis
	var basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
	dir = basis.xform(dir)
	
	# Limit the input to a length of 1. length_squared is faster to check.
	if dir.length_squared() > 1:
		dir /= dir.length()

	# Using only the horizontal velocity, interpolate towards the input.
	var hvel = velocity
	# hvel.y = 0

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


func select_object(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		# make a projection from the Camera to the button and get the object it finds
		var pos = event.position
		var from = $Camera.project_ray_origin(pos)
		var normal = $Camera.project_ray_normal(pos)
		
		var ray_start = from
		var ray_end =  from + normal * 5000 
		var space_state = get_world().direct_space_state
		return space_state.intersect_ray(ray_start, ray_end, [])

		# Does not work ?
		# $RayCast.enabled = true
		# $RayCast.cast_to = from + normal * 5000
		# $RayCast.force_raycast_update()
		# print($RayCast.get_collider())
		# print("Mouse click", event.position)
	
