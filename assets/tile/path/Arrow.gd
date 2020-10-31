extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var prev_direction = {
	Vector3( 0, 0, +1): preload("res://assets/tile/path/arrows/s0-1.png"),	# UP
	Vector3( 0, 0, -1): preload("res://assets/tile/path/arrows/s0+1.png"),	# DOWN
	Vector3(+1, 0, -1): preload("res://assets/tile/path/arrows/s-1+1.png"),
	Vector3(+1, 0,  0): preload("res://assets/tile/path/arrows/s-10.png"),
	Vector3(-1, 0, +1): preload("res://assets/tile/path/arrows/s+1-1.png"),
	Vector3(-1, 0,  0): preload("res://assets/tile/path/arrows/s+10.png"),
}


var dest_direction = {
	Vector3( 0, 0, +1): preload("res://assets/tile/path/arrows/e0+1.png"),	# UP
	Vector3( 0, 0, -1): preload("res://assets/tile/path/arrows/e0-1.png"),	# DOWN
	Vector3(+1, 0, -1): preload("res://assets/tile/path/arrows/e+1-1.png"),
	Vector3(+1, 0,  0): preload("res://assets/tile/path/arrows/e+10.png"),
	Vector3(-1, 0, +1): preload("res://assets/tile/path/arrows/e-1+1.png"),
	Vector3(-1, 0,  0): preload("res://assets/tile/path/arrows/e-10.png"),
}

var mat_cache = {}

func get_mat(d1, d2):
	var result = mat_cache.get([d1, d2])

	if result == null:
		result = $MeshInstance.get_surface_material(0).duplicate()
		result.set_shader_param("tex_frg_2", prev_direction.get(d1))
		result.set_shader_param("tex_frg_3", dest_direction.get(d2))
		mat_cache[[d1, d2]] = result
	
	return result

func __init__(d1, d2):
	$MeshInstance.set_surface_material(0, get_mat(d1, d2))
