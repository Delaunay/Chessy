extends KinematicBody

const MAX_SPEED = 5
const JUMP_SPEED = 7
const ACCELERATION = 2
const DECELERATION = 4
const MAX_SLOPE_ANGLE = 30

onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity: Vector3

var cell = null
var faction = 'X'
var index = -1

var stamina  = 100 
var strength  = 10
var agility   = 10
var intellect = 10
var vitality = 100
var crit = 0
var armor = 0
var unit_range = 4

var abilities = []
var go_to_idle = false
var dead = false
var mode = null
var rng = RandomNumberGenerator.new()
var initialized = false


func display(_viewport, _camera):
	pass
	# viewport = self
	# viewport.add_child(self)
	# camera.set_transform(self.get_transform())
	# camera.translate(Vector3(1, 0, 1))


func _ready():
	$StatusBar.set_health(vitality)
	$StatusBar.set_stamina(stamina)
	
	$ActionBar.visible = false
	# for slot in $ActionBar/Viewport/TextureRect/HBoxContainer.get_children():
	#	print(slot.get_name())
	
	# set the animation to default to make idle start at different times
	$Sprite3D.play("hitting")
	rng.randomize()
	var wtime = rng.randf_range(0, 1)
	$Timer.connect("timeout", self, "idle")
	$Timer.set_wait_time(wtime)
	$Timer.start()


func __init__(mode_):
	mode = mode_


func update_health(value):
	vitality += value
	$StatusBar.set_health(vitality)
	$CombatTextDisplay.show_value(value)

	if vitality <= 0:
		$Sprite3D.play("dead")
		$StatusBar.visible = false
		dead = true

func moving():
	$Sprite3D.play("walking")

func attack():
	$Sprite3D.play("attack")
	go_to_idle = true

func idle():
	$Sprite3D.play("idle")

func hit():
	$Sprite3D.play("hitting")
	go_to_idle = true

func hide_status():
	$StatusBar.visible = false


func animation_finished():
	return $Sprite3D.frames.get_frame_count($Sprite3D.animation) - 1 == $Sprite3D.frame


func _process(delta):
	if dead and animation_finished():
		visible = false
		mode.remove_unit(self)
		return

	if go_to_idle and animation_finished():
		idle()
		go_to_idle = false


func move_now(cell):
	translate(cell - get_global_transform().origin)


func set_color(color):
	if color != null:
		$Sprite3D.modulate = color

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
	# velocity = move_and_slide(velocity, Vector3.UP)


func _physics_process(delta):
	move(delta, Vector3(0, -1, 0))
