extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var mat_cache = {}

func get_material(kind):
	var result = mat_cache.get(kind)

	if result == null:
		result = $MeshInstance.get_surface_material(0).duplicate()
		# result.set_shader_param("tex_frg_2", prev_direction.get(d1))
		# result.set_shader_param("tex_frg_3", dest_direction.get(d2))
		mat_cache[kind] = result
	
	return result


func __init__(kind):
	$MeshInstance.set_surface_material(0, get_material(kind))


func select():
	var mat = $MeshInstance.get_material()
	mat.set_shader_param("selected", true)
	
func unselect():
	var mat = $MeshInstance.get_material()
	mat.set_shader_param("selected", false)
